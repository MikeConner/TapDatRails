class UsersController < ApplicationController
  before_filter :authenticate_user!

  def update
    respond_to do |format|
      format.js do
        user = User.find(params[:id])
        user.update_attributes(user_params)
        
        head :ok
      end
    end    
  end
    
  def dashboard  
  end

  def qrcode
    qr_uri = "bitcoin:" + current_user.inbound_btc_address

    respond_to do |format|
      format.html
      format.svg  { render :qrcode => qr_uri, :level => :l, :unit => 10, :offset => 14 }
    end    
  end
  
  def leader_board
    @tappers = []
    @tapped = Transaction.where(:dest_id => 4).select("dest_id, sum(satoshi_amount) as satoshi, sum(dollar_amount) as dollar, count(dollar_amount) as taps").group('dest_id').order('dollar DESC')
    @image_map = Hash.new
    @names_map = Hash.new
    
    @tapped.map { |t| @image_map[t.dest_id] = User.find_by_id(t.dest_id).profile_thumb.url || User.find_by_id(t.dest_id).mobile_profile_thumb_url } 
    @tapped.map { |t| @names_map[t.dest_id] = User.find_by_id(t.dest_id).name }  
  end

private
  def user_params
    params.require(:user).permit(:name)
  end
end
