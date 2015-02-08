describe Mobile::V1::CurrenciesController, :type => :controller do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe "Get a currency" do
    let(:user) { FactoryGirl.create(:user) }
    let(:currency) { FactoryGirl.create(:currency) }
    
    it "should get it" do
      get :show, :version => 1, :auth_token => user.authentication_token, :id => currency.id

      expect(subject.current_user).to eq(user)
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)

      expect(result['response']['name']).to eq(currency.name)
      expect(result['response']['icon']).to_not be_empty
      expect(result['response']['amount_per_dollar']).to eq(currency.amount_per_dollar)
      expect(result['response']['symbol']).to eq(currency.symbol)
      expect(result['response']['denominations'].count).to eq(2)
    end
  end
end