require 'bitcoin_ticker'
require 'coinbase_api'

class Mobile::V1::TransactionsController < ApiController
  before_filter :authenticate_user_from_token!

  # GET /mobile/:version/transactions[?after=2010-10-12T08:50E <earliest datetime to return, ISO format>]
  def index
    response = []

    after = params[:after].blank? ? nil : DateTime.parse(params[:after]) rescue nil
    tx_list = after.nil? ? current_user.transactions.order('created_at') : current_user.transactions.where('created_at > ?', after).order('created_at')

    tx_list.each do |tx|
      if tx.payload.nil?
        payload_image = payload_thumb = content_type = nil
      else
        payload_image = tx.payload.payload_image.url || tx.payload.mobile_payload_image_url
        payload_thumb = tx.payload.payload_image_url(:thumb).to_s || tx.payload.mobile_payload_thumb_url
        content_type = tx.payload.content_type
      end
      
      other_user = User.find(tx.dest_id)
      other_thumb = other_user.profile_image_url(:thumb).to_s || other_user.mobile_profile_thumb_url

      response.push({:id => tx.slug, :date => tx.created_at, :payload_image => payload_image, :payload_thumb => payload_thumb,
                     :payload_content_type => content_type, :amount => tx.amount, :dollar_amount => tx.dollar_amount,
                     :comment => tx.comment, :other_user_thumb => other_thumb, :other_user_nickname => other_user.name})
    end

    expose response
  end

  # POST /mobile/:version/transactions
  def create
    # current_user has the person doing the tapping
    if !params.has_key?(:tag_id)
      error! :bad_request, :metadata => {:error_description => I18n.t('missing_argument', :arg => 'tag_id'), :user_error => I18n.t('invalid_tap') }
    elsif !params.has_key?(:amount)
      error! :bad_request, :metadata => {:error_description => I18n.t('missing_argument', :arg => 'amount'), :user_error => I18n.t('invalid_tap') }
    else
      currency = params[:currency_id].blank? ? nil : Currency.find_by_id(params[:currency_id])
      # Don't get the rate if we don't need it
      rate = currency.nil? ? BitcoinTicker.instance.current_rate : nil

      amount = params[:amount].to_f

      if amount <= 0
        error! :bad_request, :metadata => {:error_description => I18n.t('invalid_amount'), :user_error => I18n.t('invalid_tap') }
      elsif rate.nil? and currency.nil?
        error! :bad_request, :metadata => {:error_description => I18n.t('rate_not_found'), :user_error => I18n.t('invalid_tap') }
      else
        tag = NfcTag.find_by_tag_id(params[:tag_id])
        if tag.nil?
           error! :not_found, :metadata => {:error_description => I18n.t('object_not_found', :obj => 'NFC Tag'), :user_error => I18n.t('invalid_tap') }
        else
          # Make sure tag is the right currency
          if !currency.nil? and (currency.id != tag.currency_id)
            error! :bad_request, :metadata => {:error_description => I18n.t('currency_mismatch'), :user_error => I18n.t('invalid_tap') } 
          else         
            payload = tag.find_payload(amount)
            if payload.nil?
              error! :not_found, :metadata => {:error_description => I18n.t('object_not_found', :obj => 'Payload'), :user_error => I18n.t('invalid_tap') }
            else
              ActiveRecord::Base.transaction do
                begin
                  # If currency is nil, it's a bitcoin transaction
                  if currency.nil?
                    # Assuming amount and rate are in dollars
                    balance = CoinbaseAPI.instance.balance_inquiry(current_user.inbound_btc_address)
                    current_user.update_attribute(:satoshi_balance, balance) unless balance.nil? or (balance == current_user.satoshi_balance)

                    multiplier = 1.0 / rate
                    transaction_amount = (amount / rate * CoinbaseAPI::SATOSHI_PER_BTC.to_f).round
                    dollar_amount = (amount * 100.0).round
                  else
                    transaction_amount = amount.round
                    dollar_amount = nil
                  end
                  
                  if currency.nil? and (current_user.satoshi_balance < transaction_amount)
                    error! :forbidden, :metadata => {:error_description => I18n.t('insufficient_funds'), :balance => current_user.satoshi_balance, :user_error => I18n.t('invalid_tap') }
                  elsif !currency.nil? and (current_user.currency_balance(currency) < transaction_amount)
                    error! :forbidden, :metadata => {:error_description => I18n.t('insufficient_funds'), :balance => current_user.currency_balance(currency), :user_error => I18n.t('invalid_tap') }
                  elsif !currency.nil? and (transaction_amount > currency.max_amount)
                    error! :forbidden, :metadata => {:error_description => I18n.t('amount_exceeds_max', :name => currency.name, :amount => transaction_amount), :balance => current_user.currency_balance(currency), :user_error => I18n.t('invalid_tap') }
                  else
                    tx = current_user.transactions.create!(transaction_params({:nfc_tag_id => tag.id,
                                                           :payload_id => payload.id,
                                                           :dest_id => tag.user.id,
                                                           :comment => payload.content,
                                                           # Store dollar amount as an integer # of cents
                                                           :dollar_amount => dollar_amount,
                                                           :amount => transaction_amount}))
                    if currency.nil?
                      tx.transaction_details.create!(details_params({:subject_id => current_user.id, :target_id => tag.user.id, :debit => transaction_amount, :conversion_rate => multiplier}))
                      tx.transaction_details.create!(details_params({:subject_id => tag.user.id, :target_id => current_user.id, :credit => transaction_amount, :conversion_rate => multiplier}))
                      
                      current_user.update_attribute(:satoshi_balance, current_user.satoshi_balance - transaction_amount)
                      tag.user.update_attribute(:satoshi_balance, tag.user.satoshi_balance + transaction_amount)
                    else
                      tx.transaction_details.create!(details_params({:subject_id => current_user.id, :target_id => tag.user.id, :debit => transaction_amount, :conversion_rate => 1, :currency => currency.name}))
                      tx.transaction_details.create!(details_params({:subject_id => tag.user.id, :target_id => current_user.id, :credit => transaction_amount, :conversion_rate => 1, :currency => currency.name}))
                      
                      tip_balance = current_user.balances.where(:currency_id => currency.id).first                   
                      tip_balance.update_attribute(:amount, tip_balance.amount - transaction_amount)
                      tag_balance = tag.user.balances.where(:currency_id => currency.id).first
                      # User might not have an initial balance in this currency
                      if tag_balance.nil?
                        tag_balance = tag.user.balances.create!(:currency_id => currency.id, :amount => transaction_amount)
                      else
                        tag_balance.update_attribute(:amount, tag_balance.amount + transaction_amount)
                      end
                    end
                    
  
                    response = {:slug => tx.slug,
                                :amount => transaction_amount,
                                :dollar_amount => dollar_amount,
                                :currency_id => params[:currency_id],
                                :final_balance => currency.nil? ? current_user.satoshi_balance : current_user.currency_balance(currency),
                                :tapped_user_thumb => tag.user.profile_image_url(:thumb).to_s || tag.user.remote_profile_thumb_url,
                                :tapped_user_name => tag.user.name,
                                :payload => {:text => payload.content,
                                             :uri => payload.uri,
                                             :image => payload.remote_payload_image_url || payload.mobile_payload_image_url,
                                             :thumb => payload.payload_image_url(:thumb).to_s || payload.mobile_payload_thumb_url,
                                             :content_type => payload.content_type}}
                    expose response
                  end
                rescue ActiveRecord::Rollback => ex
                  error! :bad_request, :metadata => {:error_description => ex.message, :user_error => I18n.t('invalid_tap') }
                end
              end
            end
          end
        end
      end
    end
  end
  
private
  def transaction_params(params)
    ActionController::Parameters.new(params).permit(:nfc_tag_id, :payload_id, :dest_id, :comment, :dollar_amount, :amount, :currency_id)
  end
  
  def details_params(params)
    ActionController::Parameters.new(params).permit(:subject_id, :target_id, :debit, :credit, :conversion_rate)
  end
end
