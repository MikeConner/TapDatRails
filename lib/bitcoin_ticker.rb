require 'singleton'

class BitcoinTicker
  include Singleton
  
  def current_rate
    uri = URI.parse("http://blockchain.info/ticker")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
          
    response = http.request(request)                 
    if response.code == '200'
      data = JSON.parse(response.body)
      rate = data['USD']['last'].to_f rescue nil
    end
    
    rate
  end  
end
