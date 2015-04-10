require 'bitcoin_ticker'

namespace :db do
  desc "Update the Bitcoin exchange rate"
  task :update_exchange_rate => :environment do
    BitcoinTicker.instance.set_current_rate
  end
end
