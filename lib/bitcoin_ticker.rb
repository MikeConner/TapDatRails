require 'singleton'

class BitcoinTicker
  include Singleton
  
  FALLBACK_RATE = 320.00
    
  def initialize
    @agent = Mechanize.new
  end
  
  def get_current_rate
    set_current_rate if 0 == BitcoinRate.count

    rate = BitcoinRate.first.rate rescue nil
    
    rate || ENV['DEFAULT_BTC_RATE'] || FALLBACK_RATE    
  end
  
  def set_current_rate   
    rate = nil
    page = @agent.get('http://blockchain.info/ticker') rescue nil
    
    unless page.nil?
      rate = JSON.parse(page.content)["USD"]["last"] rescue nil
    end
       
    unless rate.nil?
      BitcoinRate.create(:rate => rate)
    end        
  end
end
