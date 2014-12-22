class ApiController < RocketPants::Base
  include Devise::Controllers::Helpers
    
protected  
  def authenticate_user_from_token!
    @user = User.find_by_authentication_token(params[:auth_token])

    if @user.nil?
      error! :not_found, :metadata => {:error_description => I18n.t('auth_token_not_found')}
    elsif current_user.nil?
      sign_in(@user, :store => false)      
    elsif current_user.id != @user.id
      error! :forbidden, :metadata => {:error_description => I18n.t('invalid_auth_token')}      
    end    
  end
end
