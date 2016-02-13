# == Schema Information
#
# Table name: staff_members
#
#  id           :integer          not null, primary key
#  venue_id     :integer
#  user_id      :integer
#  display_name :string(255)      not null
#  first_name   :string(255)
#  last_name    :string(255)
#  age          :integer
#  body_type    :string(255)
#  ethnicity    :string(255)
#  sexuality    :string(255)
#  eye_color    :string(255)
#  hair_color   :string(255)
#  status       :string(255)
#  type         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class StaffMember < ActiveRecord::Base
  belongs_to :venue
  # A staff member is a user
  belongs_to :user
  has_many :staff_images, :dependent => :destroy
  
  validates_presence_of :display_name
  
  def main_image
    self.staff_images.first
  end
end
