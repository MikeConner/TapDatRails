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

require 'rails_helper'

RSpec.describe StaffImage, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
