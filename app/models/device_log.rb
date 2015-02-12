# == Schema Information
#
# Table name: device_logs
#
#  id         :integer          not null, primary key
#  user       :string(16)       not null
#  os         :string(32)       not null
#  hardware   :string(48)       not null
#  message    :string(255)      not null
#  details    :text
#  created_at :datetime
#  updated_at :datetime
#

class DeviceLog < ActiveRecord::Base
  OS_DESC_LIMIT = 32
  HARDWARE_DESC_LIMIT = 48
  
  validates :user, :presence => true, :length => { :maximum => User::SECRET_KEY_LEN }
  validates :os, :presence => true, :length => { :maximum => OS_DESC_LIMIT }
  validates :hardware, :presence => true, :length => { :maximum => HARDWARE_DESC_LIMIT }
  validates_presence_of :message
end
