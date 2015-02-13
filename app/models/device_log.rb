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

# CHARTER
#   Provide storage for unexplained errors that occur on devices
#
# USAGE
#   Devices can log information or errors; web app admin page can be written to display them. May want to add something else
# like a classification. (Could also use message for this now.)
#
# NOTES AND WARNINGS
#   Requires a user authentication token to avoid hacking. Assuming this will happen to logged-in users running the app.
# If it's necessary to log errors for phones that are not logged in, we could hard-code a special test user's code in the app.
#
class DeviceLog < ActiveRecord::Base
  OS_DESC_LIMIT = 32
  HARDWARE_DESC_LIMIT = 48
  
  validates :user, :presence => true, :length => { :maximum => User::SECRET_KEY_LEN }
  validates :os, :presence => true, :length => { :maximum => OS_DESC_LIMIT }
  validates :hardware, :presence => true, :length => { :maximum => HARDWARE_DESC_LIMIT }
  validates_presence_of :message
end
