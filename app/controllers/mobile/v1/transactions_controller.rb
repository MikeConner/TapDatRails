require 'bitcoin_ticker'
require 'coinbase_api'

class Mobile::V1::TransactionsController < ApiController
  before_filter :authenticate_user_from_token!

  # GET /mobile/:version/transactions
  def index
    response = []

    current_user.transactions.order('created_at DESC').each do |tx|
      payload_image = tx.payload.payload_image.url || tx.payload.mobile_payload_image_url
      payload_thumb = tx.payload.payload_thumb.url || tx.payload.mobile_payload_thumb_url
      other_user = User.find(tx.dest_id)
      other_thumb = other_user.profile_thumb.url || other_user.mobile_profile_thumb_url

      response.push({:id => tx.slug, :date => tx.created_at, :payload_image => payload_image, :payload_thumb => payload_thumb,
                     :amount => tx.amount, :dollar_amount => tx.dollar_amount,
                     :comment => tx.comment, :other_user_thumb => other_thumb, :other_user_nickname => other_user.name})
    end

    expose response
  end

  # POST /mobile/:version/transactions
  def create
    # current_user has the person doing the tapping
    if !params.has_key?(:tag_id)
      error! :bad_request, :metadata => {:error_description => I18n.t('missing_argument', :arg => 'tag_id')}
    elsif !params.has_key?(:amount)
      error! :bad_request, :metadata => {:error_description => I18n.t('missing_argument', :arg => 'amount')}
    else
      rate = nil

      amount = params[:amount].to_f
      rate = BitcoinTicker.instance.current_rate

      if amount <= 0
        error! :bad_request, :metadata => {:error_description => I18n.t('invalid_amount')}
      elsif rate.nil?
        error! :bad_request, :metadata => {:error_description => I18n.t('rate_not_found')}
      else
        tag = NfcTag.find_by_tag_id(params[:tag_id])
        if tag.nil?
           error! :not_found, :metadata => {:error_description => I18n.t('object_not_found', :obj => 'NFC Tag')}
        else
          payload = tag.find_payload(amount)
          if payload.nil?
            error! :not_found, :metadata => {:error_description => I18n.t('object_not_found', :obj => 'Payload')}
          else
            ActiveRecord::Base.transaction do
              begin
                # Assuming amount and rate are in dollars
                multiplier = 1.0 / rate
                satoshi = (amount / rate * CoinbaseAPI::SATOSHI_PER_BTC.to_f).round

                if current_user.satoshi_balance < satoshi
                  error! :forbidden, :metadata => {:error_description => I18n.t('insufficient_funds'), :balance => current_user.satoshi_balance }
                else
                  tx = current_user.transactions.create!(transaction_params({:nfc_tag_id => tag.id,
                                                         :payload_id => payload.id,
                                                         :dest_id => tag.user.id,
                                                         :comment => payload.content,
                                                         # Store dollar amount as an integer # of cents
                                                         :dollar_amount => (amount * 100.0).round,
                                                         :amount => satoshi}))
                  tx.transaction_details.create!(details_params({:subject_id => current_user.id, :target_id => tag.user.id, :debit => satoshi, :conversion_rate => multiplier}))
                  tx.transaction_details.create!(details_params({:subject_id => tag.user.id, :target_id => current_user.id, :credit => satoshi, :conversion_rate => multiplier}))

                  current_user.update_attribute(:satoshi_balance, current_user.satoshi_balance - satoshi)
                  tag.user.update_attribute(:satoshi_balance, tag.user.satoshi_balance + satoshi)

                  response = {:amount => satoshi,
                              :dollar_amount => (amount * 100.0).round,
                              :final_balance => current_user.satoshi_balance,
                              :tapped_user_thumb => tag.user.profile_thumb || tag.user.remote_profile_thumb_url,
                              :tapped_user_name => tag.user.name,
                              :payload => {:text => payload.content,
                                           :uri => payload.uri,
                                           :image => payload.remote_payload_image_url || payload.mobile_payload_image_url,
                                           :thumb => payload.remote_payload_thumb_url || payload.mobile_payload_thumb_url}}
                  expose response
                end
              rescue ActiveRecord::Rollback => ex
                error! :bad_request, :metadata => {:error_description => ex.message}
              end
            end
          end
        end
      end
    end
  end
  
private
  def transaction_params(params)
    ActionController::Parameters.new(params).permit(:nfc_tag_id, :payload_id, :dest_id, :comment, :dollar_amount, :amount)
  end
  
  def details_params(params)
    ActionController::Parameters.new(params).permit(:subject_id, :target_id, :debit, :credit, :conversion_rate)
  end
end
