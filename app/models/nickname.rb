# == Schema Information
#
# Table name: nicknames
#
#  id         :integer          not null, primary key
#  column     :integer          not null
#  word       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Nickname < ActiveRecord::Base
  attr_accessible :column, :word
  
  validates :column, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates_presence_of :word
end
