# == Schema Information
#
# Table name: balances
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  amount          :integer          default(0), not null
#  expiration_date :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  currency_id     :integer
#

# CHARTER
#
#  Encapsulate a user's interaction with a particular currency. Link to Currency (see NOTES).
#    Currencies are owned by issuing users, but vouchers are owned by individuals.
#
# USAGE
#
# NOTES AND WARNINGS
#   The Android app wants the id vs. the name, so we're storing that instead of just the name. I don't like that it creates ambiguity, so
# it deliberately doesn't have the corresponding has_many
#
class Balance < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency
  
  validates :amount, :numericality => { :only_integer => true, :greater_than_or_equal => 0 }
end
