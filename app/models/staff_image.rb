# == Schema Information
#
# Table name: staff_images
#
#  id                       :integer          not null, primary key
#  staff_member_id          :integer
#  caption                  :string(255)
#  profile_image            :string(255)
#  profile_image_processing :boolean
#  created_at               :datetime
#  updated_at               :datetime
#

class StaffImage < ActiveRecord::Base
  belongs_to :staff_member
  
  mount_uploader :profile_image, ImageUploader
  process_in_background :profile_image
  
  validates_presence_of :profile_image
end
