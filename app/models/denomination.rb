# == Schema Information
#
# Table name: denominations
#
#  id          :integer          not null, primary key
#  currency_id :integer
#  value       :integer
#  image       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Denomination < ActiveRecord::Base
  mount_uploader :image, ImageUploader
  process_in_background :image
  
  belongs_to :currency
  
  validates :value, :numericality => { :only_integer => true, :greater_than => 0 }
end
