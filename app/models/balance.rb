# == Schema Information
#
# Table name: balances
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  currency_name   :string(255)      not null
#  amount          :integer          default(0), not null
#  expiration_date :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

# CHARTER
#
#  Encapsulate a user's interaction with a particular currency. Link to Currency through the name (not a direct link, to avoid ambiguity.
#    currencies are owned by issuing users, but vouchers are owned by individuals)
#
# USAGE
#
# NOTES AND WARNINGS
#
class Balance < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :currency_name  
  validates :amount, :numericality => { :only_integer => true, :greater_than_or_equal => 0 }
end
