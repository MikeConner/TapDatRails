class Mobile::V1::SessionsController < ApiController
  before_filter :after_token_authentication

  # POST /mobile/:version/sessions
  def create
    response = {:nickname => @user.name}
    expose response
  end
  
  # DELETE /mobile/:version/sessions/:id
  def destroy
    @user.update_attribute(:authentication_token, nil)
    sign_out @user
    head :ok
  end
end
