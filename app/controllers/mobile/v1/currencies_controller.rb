class Mobile::V1::CurrenciesController < ApiController
  before_filter :authenticate_user_from_token!
  
  def index
    currencies = Hash.new
    current_user.currencies.each do |currency|
      currencies[currency.name] = currency.decode_denominations
    end
    
    expose currencies
  end
end
