require 'nickname_generator'

class Mobile::V1::RegistrationsController < ApiController
  def create
    if params.has_key?(:user)
      if params[:user].has_key?(:phone_secret_key)
        begin
          email = params[:user][:email] || SecureRandom.hex(16) + User::UNKNOWN_EMAIL_DOMAIN
          password = params[:user][:password] || SecureRandom.hex(32)
          name = params[:user][:nickname] || NicknameGenerator.generate_nickname
          
          user = User.create!(:email => email, 
                              :password => password, 
                              :password_confirmation => password, 
                              :name => name,
                              # Temporarily create with a bitcoin address
                              :inbound_btc_address => Faker::Bitcoin.address,
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
