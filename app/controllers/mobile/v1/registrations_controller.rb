require 'nickname_generator'
require 'coinbase_api'

class Mobile::V1::RegistrationsController < ApiController
  def create
    if params.has_key?(:user)
      if params[:user].has_key?(:phone_secret_key)
        begin
          email = params[:user][:email] || SecureRandom.hex(16) + User::UNKNOWN_EMAIL_DOMAIN
          password = params[:user][:password] || SecureRandom.hex(32)
          name = params[:user][:nickname] || NicknameGenerator.generate_nickname
          # Strip off domain
          if Rails.env.production?
            btc_address = CoinbaseAPI.instance.create_inbound_address(/(.*?)@/.match(email)[1]) rescue nil
          else
            btc_address = Faker::Bitcoin.address 
          end
          
          user = User.create!(:email => email, 
                              :password => password, 
                              :password_confirmation => password, 
                              :name => name,
                              # Temporarily create with a bitcoin address
                              :inbound_btc_address => btc_address,
                              :phone_secret_key => params[:user][:phone_secret_key])                             
          sign_in user

          response = {:nickname => user.name, :auth_token => user.authentication_token}
          expose response
        rescue Exception => ex
          error! :bad_request, :metadata => {:error_description => ex.message}
        end
      else
        error! :bad_request, :metadata => {:error_description => I18n.t('missing_argument', :arg => 'phone secret key')}
      end
    else
      error! :bad_request, :metadata => {:error_description => I18n.t('missing_argument', :arg => 'user')}
    end
  end    
end
