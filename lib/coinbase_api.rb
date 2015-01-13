require 'singleton'

class CoinbaseAPI
  include Singleton
  
  # Minimum satoshi balance required for cashout
  WITHDRAWAL_THRESHOLD = 50000
  TEST_BUY = 350.0
  TEST_SELL = 345.0
  SATOSHI_PER_BTC = 100000000
  
  attr_accessor :api
  
  # api is nil if we're testing
  def initialize
    if COINBASE_API_KEY.nil? or COINBASE_SECRET_KEY.nil?
      Rails.logger.info "Cannot initialize Coinbase"
    else
      self.api = Rails.env.test? ? nil : Coinbase::Client.new(COINBASE_API_KEY, COINBASE_SECRET_KEY)
      @agent = Mechanize.new
    end
  end
  
  # This is not our entire account balance (which the Coinbase API would provide)
  # We want the balance of *one* of the addresses, which we can get from Blockchain
  def balance_inquiry(address)  
    begin
      page = @agent.get("https://blockchain.info/q/addressbalance/#{address}")
    rescue Exception => ex
      Rails.logger.error "Could not get balance on #{address} - #{ex.inspect}"
      page = nil
    end
    
    unless page.nil?
      if page.code == '200'
        return page.content.to_i
      end
    end
    
    nil
  rescue
    nil
  end
  
  def buy_price(qty = 1.0)
    Rails.env.test? ? TEST_BUY : self.api.buy_price(qty).to_f rescue nil   
  end

  def sell_price(qty = 1.0)
    Rails.env.test? ? TEST_SELL : self.api.sell_price(qty).to_f rescue nil   
  end
  
  def withdraw(from_address, to_address, satoshi)
    if Rails.env.test?
      {:success => true, :id => SecureRandom.hex(12), :data => {:fish => 234}}
    else
      response = self.api.send_money(to_address, satoshi.to_f / SATOSHI_PER_BTC.to_f, "Cashout #{from_address} -> #{to_address}")
      
      {:success => response.success?, :id => response.transaction.id, :data => response.to_hash}
    end
  rescue Exception => ex
    {:success => false, :error => ex.message}
  end
  
  def create_inbound_address(label)
    unless self.api.nil?
      if label.blank?
        # This is an app policy, so we can keep track of them; can also set up callbacks if we need to
        Rails.logger.info "Must label all new addresses"
      else
        result = self.api.generate_receive_address(:address => {:label => label})
        if result['success']
          return result['address']
        end
      end
    end
    
    Rails.env.test? ? Faker::Bitcoin.address : nil
  rescue 
    nil
  end
end
