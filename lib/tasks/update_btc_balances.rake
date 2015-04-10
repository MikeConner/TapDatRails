require 'coinbase_api'

namespace :db do
  desc "Update the Bitcoin balances"
  task :update_btc_balances => :environment do
    BalanceCache.find_in_batches(:batch_size => 20).each do |batch|
      batch.each do |entry|
        # Second argument forces it
        CoinbaseAPI.instance.balance_inquiry(entry.btc_address, true)      
      end
      
      sleep 10
    end
  end
end
