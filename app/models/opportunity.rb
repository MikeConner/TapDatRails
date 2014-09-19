# == Schema Information
#
# Table name: opportunities
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  location   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Opportunity < ActiveRecord::Base
  attr_accessible :email, :location, :name
end
