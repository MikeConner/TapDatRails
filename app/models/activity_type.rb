# == Schema Information
#
# Table name: activity_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

class ActivityType < ActiveRecord::Base
  validates_presence_of :name
end
