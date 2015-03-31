# == Schema Information
#
# Table name: nicknames
#
#  id         :integer          not null, primary key
#  column     :integer          not null
#  word       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

# CHARTER
#   Class to store the raw data for nickname generators. The nicknames table consists of n columns of words/phrases.
# A generator is defined by a range of columns (e.g., 1..2, 17..19); a nickname consists of the concatenation of 
# one word drawn at random from each of the specified columns.
#
# USAGE
#
# NOTES AND WARNINGS
#
class Nickname < ActiveRecord::Base
  validates :column, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates_presence_of :word
end
