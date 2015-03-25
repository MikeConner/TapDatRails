class UsersController < ApplicationController
  before_filter :authenticate_user!

  # PUT /users/:id
  def update
    respond_to do |format|
      format.js do
        user = User.find(params[:id])
        old_email = user.email

        user.update_attributes(user_params)

        user.reset_password unless (user.email == old_email) or user.generated_email?

        head :ok
      end
    end
  end

  # GET /users/:id
  def show
    @user = User.find(params[:id])
  end

  # GET /users/:id/qrcode
  def qrcode
    qr_uri = "bitcoin:" + current_user.inbound_btc_address

    respond_to do |format|
      format.html
      format.svg  { render :qrcode => qr_uri, :level => :l, :unit => 10, :offset => 14 }
    end
  end

  # GET /users/:id/leader_board
  def leader_board
    # Deferred
  end

private
  def user_params
    params.require(:user).permit(:name)
  end
end
