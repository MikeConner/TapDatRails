require 'singleton'

class CoinbaseAPI
  include Singleton
  
  attr_accessor :api
  
  def initialize
    if COINBASE_API_KEY.nil? or COINBASE_SECRET_KEY.nil?
      Rails.logger.info "Cannot initialize Coinbase"
    else
      self.api = Coinbase::Client.new(COINBASE_API_KEY, COINBASE_SECRET_KEY)
    end
  end
  
  # This is not our entire account balance (which the Coinbase API would provide)
  # We want the balance of *one* of the addresses, which we can get from Blockchain
  def balance_inquiry(address)    
    uri = URI.parse("https://blockchain.info/q/addressbalance/#{address}")
    http = Net::HTTP.new(uri.host)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request) 
    
    if response.code == '200'
      return response.body.to_i
    end
    
    nil
  rescue
    nil
  end
  
  def buy_price(qty = 1.0)
    self.api.buy_price(qty).to_f rescue nil   
  end

  def sell_price(qty = 1.0)
    self.api.sell_price(qty).to_f rescue nil   
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
    
    nil
  rescue 
    nil
  end
end
