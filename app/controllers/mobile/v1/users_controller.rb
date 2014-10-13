require 'nickname_generator'
require 'coinbase_api'

class Mobile::V1::UsersController < ApiController
  before_filter :after_token_authentication

  # GET /mobile/:version/users/:id
  def show
    response = {:nickname => current_user.name,
                :email => current_user.generated_email? ? '' : current_user.email,
                :inbound_btc_address => current_user.inbound_btc_address,
                :inbound_btc_qrcode => current_user.inbound_btc_qrcode,
                :outbound_btc_address => current_user.outbound_btc_address,
                :satoshi_balance => current_user.satoshi_balance,
                :profile_image => current_user.remote_profile_image_url || current_user.mobile_profile_image_url,
                :profile_thumb => current_user.remote_profile_thumb_url || current_user.mobile_profile_thumb_url}
    expose response

  rescue Exception => ex
    error! :bad_request, :metadata => {:error_description => ex.message}
  end

  # GET /mobile/:version/users/balance_inquiry
  def balance_inquiry
    if current_user.inbound_btc_address.nil?
      error! :not_found, :metadata => {:error_description => I18n.t('no_btc_address')}
    else
      balance = CoinbaseAPI.instance.balance_inquiry(current_user.inbound_btc_address)
      if balance.nil?
        error! :not_found, :metadata => {:error_description => I18n.t('address_not_found')}
      else
        price = [0, CoinbaseAPI.instance.sell_price(balance)].max

        response = {:btc_balance => balance,
                    :dollar_balance => price,
                    :exchange_rate => (balance.nil? or (0 == balance)) ? nil : price / balance}
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

    if current_user.update_attributes(params[:user])
      response = {:nickname => current_user.name,
                  :email => current_user.email,
                  :inbound_btc_address => current_user.inbound_btc_address,
                  :outbound_btc_address => current_user.outbound_btc_address,
                  :mobile_profile_thumb_url => current_user.mobile_profile_thumb_url,
                  :mobile_profile_image_url => current_user.mobile_profile_thumb_url }
      expose response
    end
    puts current_user.errors.full_messages
  rescue Exception => ex
    puts.ex.message
    error! :bad_request, :metadata => {:error_description => ex.message}
  end

  # PUT /mobile/:version/users/reset_nickname
  def reset_nickname
    current_user.update_attribute(:name, NicknameGenerator.generate_nickname)

    response = {:nickname => current_user.name}
    expose response

  rescue Exception => ex
    error! :bad_request, :metadata => {:error_description => ex.message}
  end
end
