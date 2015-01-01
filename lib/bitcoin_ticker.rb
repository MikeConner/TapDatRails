require 'singleton'

class BitcoinTicker
  include Singleton
  
  FALLBACK_RATE = 320.00
    
  def initialize
    @agent = Mechanize.new
  end
  
  def current_rate   
    rate = nil
    page = @agent.get('http://blockchain.info/ticker') rescue nil
    
    unless page.nil?
      rate = JSON.parse(page.content)["USD"]["last"] rescue nil
    end
       
    if rate.nil?
      rate = BitcoinRate.first.rate rescue nil
    end
    
    unless rate.nil?
      BitcoinRate.create(:rate => rate)
    end    
    
    rate || ENV['DEFAULT_BTC_RATE'] || FALLBACK_RATE
  end
end
