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
  end
end
