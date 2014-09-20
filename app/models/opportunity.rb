# == Schema Information
#
# Table name: opportunities
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)      not null
#  location   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Opportunity < ActiveRecord::Base
  include ApplicationHelper
  
  attr_accessible :email, :location, :name
  
  validates :email, :uniqueness => { case_sensitive: false },
                    :format => { with: EMAIL_REGEX }
end
