# == Schema Information
#
# Table name: opportunities
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)      not null
#  location   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

# CHARTER
#   Capture emails for later spamming.
#
# USAGE
#   Location and name are optional; store if given.
#
# NOTES AND WARNINGS
#
class Opportunity < ActiveRecord::Base
  include ApplicationHelper
  
  validates :email, :uniqueness => { case_sensitive: false },
                    :format => { with: EMAIL_REGEX }
end
