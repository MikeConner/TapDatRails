namespace :db do
  desc "Set fallback bitcoin rate, in case BitcoinTicker is down"
  task :set_fallback_btc_rate, [:rate] => :environment do |t, args|
    if !args.has_key?(:rate)
      puts "Please enter a rate (e.g., rake db:set_fallback_btc_rate[327.29])"
    else
      BitcoinRate.create(:rate => args[:rate])
    end
  end
end
