class Mobile::V1::CurrenciesController < ApiController
  before_filter :authenticate_user_from_token!
  
  def show
    denoms = Array.new
    currency = Currency.find_by_id(params[:id])
    currency.denominations.each do |d|
      denoms.push({:amount => d.value, :image => d.image.url})
    end
    
    expose main_object(currency).merge({
      denominations: denoms
    })
            
  end
  
private
  def main_object(currency)
    {:name => currency.name,
     :icon => currency.icon.url,
     :amount_per_dollar => currency.amount_per_dollar,
     :max_amount => currency.max_amount,
     :symbol => currency.symbol}
  end
end
