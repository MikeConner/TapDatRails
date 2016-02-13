# == Schema Information
#
# Table name: venues
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  name                  :string(255)      not null
#  address_1             :string(255)
#  address_2             :string(255)
#  city                  :string(255)
#  state                 :string(255)
#  zipcode               :integer
#  website               :string(255)
#  facebook              :string(255)
#  twitter               :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  slug                  :string(255)
#  main_image            :string(255)
#  main_image_processing :boolean
#  activity_type_id      :integer          default(1), not null
#

class Venue < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [:slugged, :history, :finders]

  # This user is the owner/administrator
  belongs_to :user
  belongs_to :activity_type
  has_many :staff_members
  
  accepts_nested_attributes_for :staff_members, :allow_destroy => true, :reject_if => :all_blank
  
  mount_uploader :main_image, ImageUploader
  process_in_background :main_image
  
  validates_presence_of :name
  
  def currency
    user.currencies.first
  end
end
