class StaticPagesController < ApplicationController
  respond_to :html, :js
  
  def home
  end

  def legal
  end

  def privacy
  end

  def contact  
  end
  
  def how_it_works
  end
  
  def leader_board
    @tappers = Transaction.select("user_id, sum(amount) as satoshi, sum(dollar_amount) as total, count(user_id) as taps").group('user_id').order('total DESC')
    @tapped = Transaction.select("nfc_tag_id, sum(amount) as satoshi, sum(dollar_amount) as total, count(user_id) as taps").group('nfc_tag_id').order('total DESC')
    @image_map = Hash.new
    @names_map = Hash.new

    @tappers.map { |t| @image_map[t.user_id] = t.user.mobile_profile_thumb_url || t.user.profile_image_url(:thumb).to_s } 
    @tappers.map { |t| @names_map[t.user_id] = User.find_by_id(t.user_id).name } 
    @tapped.map { |t| @names_map[t.nfc_tag_id] = NfcTag.find_by_id(t.nfc_tag_id).name unless t.nfc_tag_id.nil? } 
  end
  
  def thumb_dimensions
    render :json => {:width => ImageUploader::THUMB_WIDTH, :height => ImageUploader::THUMB_HEIGHT}
  end
end
