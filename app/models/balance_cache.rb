# == Schema Information
#
# Table name: balance_caches
#
#  id          :integer          not null, primary key
#  btc_address :string(36)       not null
#  satoshi     :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#

# CHARTER
#   Cache the satoshi balance associated with a given bitcoin address (ultimate source: blockchain). Cut down drastically on API calls.
#
# USAGE
#   Read from here instead of going to the blockchain; periodically update the balances from the blockchain with an offline process.
##
# NOTES AND WARNINGS
#  If an accurate balance is needed (e.g., withdrawals), always go to the blockchain.
#
class BalanceCache < ActiveRecord::Base
  # Gross format validation; not going nuts and actually validating the checksum
  validates :btc_address, :presence => true,
                          :length => { :maximum => 36 }, 
                          :format => { :with => /\A(1|3)[a-zA-Z1-9]{26,33}\z/ }
  validates :satoshi, :presence => true, 
                      :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
end
