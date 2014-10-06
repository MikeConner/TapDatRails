require 'nickname_generator'

class Mobile::V1::UsersController < ApiController
  before_filter :after_token_authentication

  # GET /mobile/:version/users/:id
  def show
    response = {:nickname => current_user.name, 
                :email => current_user.email, 
                :inbound_btc_address => current_user.inbound_btc_address,
                :outbound_btc_address => current_user.outbound_btc_address,
                :satoshi_balance => current_user.satoshi_balance,
                :profile_image => current_user.remote_profile_image_url || current_user.mobile_profile_image_url,
                :profile_thumb => current_user.remote_profile_thumb_url || current_user.mobile_profile_thumb_url}    
    expose response

  rescue Exception => ex
    error! :bad_request, :metadata => {:error_description => ex.message}
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
                  :outbound_btc_address => current_user.outbound_btc_address}    
      expose response     
    end
    
  rescue Exception => ex
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
