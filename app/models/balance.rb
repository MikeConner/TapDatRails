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
#   The expiration date gets bumped up to the expiration date of the voucher (as determined by the expiration_days field in the associated currency)
# If there are any active vouchers in this balance at the time a new one is added or a tap is attempted, and the date is passed, all the existing vouchers
# are marked expired. Also, the currency owner can set a currency to inactive (e.g., when the event is over), which automatically expires all associated
# active vouchers.
#
# NOTES AND WARNINGS
#
class Balance < ActiveRecord::Base
  #attr_accessible :currency_name, :expiration_date, 
  #                :user_id
  
  belongs_to :user
  has_many :vouchers, :dependent => :destroy
  
  validates_presence_of :currency_name
  
  def amount
    vouchers.active.sum(:amount)
  end
end
