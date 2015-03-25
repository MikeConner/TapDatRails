require 'nickname_generator'
require 'coinbase_api'

class Mobile::V1::UsersController < ApiController
  before_filter :authenticate_user_from_token!

  # GET /mobile/:version/users/:id
  def show
    response = {:nickname => current_user.name,
                :email => current_user.generated_email? ? '' : current_user.email,
                :inbound_btc_address => current_user.inbound_btc_address,
                :inbound_btc_qrcode => current_user.inbound_btc_qrcode,
                :outbound_btc_address => current_user.outbound_btc_address,
                :satoshi_balance => current_user.satoshi_balance,
                :profile_image => current_user.profile_image.url || current_user.mobile_profile_image_url,
                :profile_thumb => current_user.profile_image_url(:thumb).to_s || current_user.mobile_profile_thumb_url}
    expose response

  rescue Exception => ex
    error! :bad_request, :metadata => {:error_description => ex.message, :user_error => I18n.t('invalid_user_details') }
  end

  # GET /mobile/:version/users/balance_inquiry
  def balance_inquiry
    if current_user.inbound_btc_address.nil?
      error! :not_found, :metadata => {:error_description => I18n.t('no_btc_address'), :user_error => I18n.t('invalid_bitcoin_addr') }
    else
      # Result will be in Satoshi
      balance = CoinbaseAPI.instance.balance_inquiry(current_user.inbound_btc_address)
      if balance.nil?
        error! :not_found, :metadata => {:error_description => I18n.t('address_not_found') + ': User:' + current_user.id.to_s, :user_error => I18n.t('invalid_bitcoin_addr') }
      else
        current_user.update_attribute(:satoshi_balance, balance) unless balance == current_user.satoshi_balance
        
        price = 0 == balance ? 0 : [0, CoinbaseAPI.instance.sell_price(balance.to_f / CoinbaseAPI::SATOSHI_PER_BTC.to_f)].max

        response = {:btc_balance => balance,
                    :dollar_balance => price,
                    :exchange_rate => (balance.nil? or (0 == balance)) ? nil : price / balance}

        response[:balances] = []
        current_user.balances.each do |bal|
          response[:balances].push({:id => bal.currency.id, :amount => bal.amount})
        end

        expose response
      end
    end
  end

  # PUT /mobile/:version/users/:id
  def update
    # Ensure we don't update fields we aren't allowed to change
    params[:user].delete(:phone_secret_key)
    params[:user].delete(:authentication_token)
    params[:user].delete(:inbound_btc_address)
    params[:user].delete(:satoshi_balance)
    old_email = current_user.email
    
    if current_user.update_attributes(user_params)
      current_user.reset_password unless (current_user.email == old_email) or current_user.generated_email?
      
      response = {:nickname => current_user.name,
                  :email => current_user.email,
                  :inbound_btc_address => current_user.inbound_btc_address,
                  :outbound_btc_address => current_user.outbound_btc_address,
                  :mobile_profile_thumb_url => current_user.mobile_profile_thumb_url,
                  :mobile_profile_image_url => current_user.mobile_profile_thumb_url }
      expose response
    end
  rescue Exception => ex
    error! :bad_request, :metadata => {:error_description => ex.message, :user_error => I18n.t('user_update_error') }
  end

  # PUT /mobile/:version/users/reset_nickname
  def reset_nickname
    current_user.update_attribute(:name, NicknameGenerator.generate_nickname)

    response = {:nickname => current_user.name}
    expose response

  rescue Exception => ex
    error! :bad_request, :metadata => {:error_description => ex.message, :user_error => I18n.t('nickname_reset_error')}
  end

  # PUT /mobile/:version/users/cashout
  def cashout
    if current_user.satoshi_balance < CoinbaseAPI::WITHDRAWAL_THRESHOLD
      error! :bad_request, :metadata => {:error_description => I18n.t('insufficient_funds'), :user_error => I18n.t('cashout_error') }
    elsif current_user.inbound_btc_address.nil? or current_user.outbound_btc_address.nil?
      error! :bad_request, :metadata => {:error_description => I18n.t('invalid_btc_addresses'), :user_error => I18n.t('cashout_error') }
    else
      ActiveRecord::Base.transaction do
        # Create details
        satoshi = current_user.satoshi_balance

        tx = current_user.transactions.create!(:dest_id => current_user.id,
                                               :comment => "Cashout of #{satoshi} (#{current_user.inbound_btc_address} to #{current_user.outbound_btc_address})",
                                               # Store dollar amount as an integer # of cents
                                               :amount => satoshi)
        tx.transaction_details.create!(:subject_id => current_user.id, :target_id => current_user.id, :debit => satoshi, :conversion_rate => 1.0)

        current_user.update_attribute(:satoshi_balance, 0)

        response = CoinbaseAPI.instance.withdraw(current_user.inbound_btc_address, current_user.outbound_btc_address, satoshi)
        unless response[:success]
          raise "transaction aborted: #{response.inspect}"
        end

        expose response
      end
    end
  end

  def redeem_voucher
    # Lookup voucher; ensure it's active. Assign voucher's user, update user's balance
    voucher = Voucher.find_by_uid(params[:id])
    if voucher.nil?
      # It could be a single code voucher -- look for it
      generator = SingleCodeGenerator.find_by_code(params[:id])
      if !generator.nil? and (generator.code == params[:id]) and generator.active?
        reserve = generator.currency.reserve_balance
        if reserve < generator.value
          error! :bad_request, :metadata => {:error_description => I18n.t('insufficient_funds'), :user_error => I18n.t('redemption_error') }
        else  
          if current_user.transactions.where(:comment => I18n.t('single_code_redemption', :code => params[:id])).empty?
            ActiveRecord::Base.transaction do
              voucher = generator.currency.vouchers.create!(:uid => SecureRandom.hex(4), :amount => generator.value, :user_id => current_user.id)
              generator.currency.update_attribute(:reserve_balance, reserve - generator.value)
              
              tx = current_user.transactions.create!(transaction_params(:dest_id => generator.currency.user.id,
                                                                        :voucher_id => voucher.id, 
                                                                        :amount => generator.value, 
                                                                        :comment => I18n.t('single_code_redemption', :code => params[:id])))
                                                                   
              tx.transaction_details.create!(details_params({:subject_id => current_user.id, :target_id => voucher.currency.user.id, :debit => voucher.amount, :conversion_rate => 1, :currency => voucher.currency.name}))
              tx.transaction_details.create!(details_params({:subject_id => voucher.currency.user.id, :target_id => current_user.id, :credit => voucher.amount, :conversion_rate => 1, :currency => voucher.currency.name}))
            end
          else
            error! :bad_request, :metadata => {:error_description => I18n.t('already_redeemed_voucher'), :user_error => I18n.t('redemption_error') }
          end
        end
      end
    end
    
    if voucher.nil?
      error! :not_found, :metadata => {:error_description => I18n.t('voucher_not_found', :uid => params[:id]), :user_error => I18n.t('redemption_error') }
    elsif !voucher.active?
      error! :bad_request, :metadata => {:error_description => I18n.t('inactive_voucher', :uid => params[:id]), :user_error => I18n.t('redemption_error') }
    else
      # Predefine response; this should never happen
      response = {:error => true, :metadata => {:error_description => 'Transaction DB error'}, :user_error => nil }

      ActiveRecord::Base.transaction do
        voucher.update_attribute(:status, Voucher::REDEEMED)
        voucher.update_attribute(:user_id, current_user.id)

        tx = current_user.transactions.create!(transaction_params({
                                               :dest_id => voucher.currency.user.id,
                                               :voucher_id => voucher.id,
                                               :comment => "Voucher redemption",
                                               :amount => voucher.amount}))
        tx.transaction_details.create!(details_params({:subject_id => current_user.id, :target_id => voucher.currency.user.id, :debit => voucher.amount, :conversion_rate => 1, :currency => voucher.currency.name}))
        tx.transaction_details.create!(details_params({:subject_id => voucher.currency.user.id, :target_id => current_user.id, :credit => voucher.amount, :conversion_rate => 1, :currency => voucher.currency.name}))
        
        # Update balance
        balance = current_user.balances.find_or_create_by(:currency_id => voucher.currency.id)
        total = voucher.currency.vouchers.redeemed.where(:user_id => current_user.id).sum(:amount)
        balance.update_attribute(:amount, total)
        currency = voucher.currency
        
        response = {:balance => total, 
                    :amount_redeemed => voucher.amount, 
                    :currency => {:icon => currency.icon.nil? ? nil : currency.icon.url, 
                                  :symbol => currency.symbol,
                                  :name => currency.name,
                                  :id => currency.id}}
      end

      expose response
    end    
  end
  
private
  def user_params
    params.require(:user).permit(:name, :email, :inbound_btc_address, :outbound_btc_address, :mobile_profile_image_url, :mobile_profile_thumb_url)
  end

  def transaction_params(params)
    ActionController::Parameters.new(params).permit(:nfc_tag_id, :payload_id, :dest_id, :comment, :dollar_amount, :amount, :currency_id, :voucher_id)
  end
  
  def details_params(params)
    ActionController::Parameters.new(params).permit(:subject_id, :target_id, :debit, :credit, :conversion_rate)
  end
end
