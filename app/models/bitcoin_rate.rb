# == Schema Information
#
# Table name: bitcoin_rates
#
#  id         :integer          not null, primary key
#  rate       :float
#  created_at :datetime
#  updated_at :datetime
#

# CHARTER
#
#  Fallback bitcoin exchange rate, in case BitcoinTicker is offline.
#
# USAGE
#   Attempt to get the current USD/Bitcoin exchange rate from the blockchain ticker. If it is unavailable, read from the database.
#   Since there seem to be performance/getting blocked by the API issues with this, the updated strategy is to always get it from
#   the database, and run a periodic script to update it.
#
# NOTES AND WARNINGS
#   There is also a db:set_fallback_btc_rate[327.19] rake task to set the value manually if necessary. 
#
class BitcoinRate < ActiveRecord::Base
  before_save :single_record

  validates :rate, :numericality => { :greater_than => 0 }
  
private
  def single_record
    if BitcoinRate.count > 0
      BitcoinRate.destroy_all
    end
  end
end
