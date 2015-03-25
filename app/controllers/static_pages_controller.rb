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
    @tappers = Transaction.select("user_id, sum(amount) as satoshi, sum(dollar_amount) as dollar, count(dollar_amount) as taps").group('user_id').order('dollar DESC')
    @tapped = Transaction.select("dest_id, sum(amount) as satoshi, sum(dollar_amount) as dollar, count(dollar_amount) as taps").group('dest_id').order('dollar DESC')
    @image_map = Hash.new
    @names_map = Hash.new
    
    @tappers.map { |t| @image_map[t.user_id] = t.user.profile_image_url(:thumb).to_s || t.user.mobile_profile_thumb_url } 
    @tapped.map { |t| @image_map[t.dest_id] = User.find_by_id(t.dest_id).profile_image_url(:thumb).to_s || User.find_by_id(t.dest_id).mobile_profile_thumb_url } 
    @tappers.map { |t| @names_map[t.user_id] = User.find_by_id(t.user_id).name } 
    @tapped.map { |t| @names_map[t.dest_id] = User.find_by_id(t.dest_id).name } 
  end
  
  def thumb_dimensions
    render :json => {:width => ImageUploader::THUMB_WIDTH, :height => ImageUploader::THUMB_HEIGHT}
  end
end
