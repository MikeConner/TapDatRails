require 'bitcoin_ticker'

class Mobile::V1::TransactionsController < ApiController
  before_filter :after_token_authentication
  
  def create
    # current_user has the person doing the tapping
    if !params.has_key?(:tag_id)
      error! :bad_request, :metadata => {:error_description => I18n.t('missing_argument', :arg => 'tag_id')}
    elsif !params.has_key?(:amount)
      error! :bad_request, :metadata => {:error_description => I18n.t('missing_argument', :arg => 'amount')}
    else
      rate = nil
      
      amount = params[:amount].to_f
      3.times do
        rate = BitcoinTicker.instance.current_rate
        if rate.nil?
          sleep 5
        else
          break
        end
      end
      
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
                satoshi = (amount / rate * 100000000.0).round
                
                if current_user.satoshi_balance < satoshi
                  error! :forbidden, :metadata => {:error_description => I18n.t('insufficient_funds'), :balance => current_user.satoshi_balance }
                else
                  tx = current_user.transactions.create!(:nfc_tag_id => tag.id, 
                                                         :payload_id => payload.id, 
                                                         :dest_id => tag.user.id,
                                                         # Store dollar amount as an integer # of cents
                                                         :dollar_amount => (amount * 100.0).round, 
                                                         :satoshi_amount => satoshi)  
                  tx.transaction_details.create!(:subject_id => current_user.id, :target_id => tag.user.id, :debit_satoshi => satoshi, :conversion_rate => multiplier)      
                  tx.transaction_details.create!(:subject_id => tag.user.id, :target_id => current_user.id, :credit_satoshi => satoshi, :conversion_rate => multiplier)      
                  
                  current_user.update_attribute(:satoshi_balance, current_user.satoshi_balance - satoshi)
                  tag.user.update_attribute(:satoshi_balance, tag.user.satoshi_balance + satoshi)  
                  
                  response = {:satoshi => satoshi, :payload => {:uri => payload.uri, :text => payload.content}}
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
end
