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

class Performer < StaffMember
end
