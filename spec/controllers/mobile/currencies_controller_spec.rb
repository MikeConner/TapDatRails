describe Mobile::V1::CurrenciesController, :type => :controller do
  let(:user) { FactoryGirl.create(:user_with_currencies) }

  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "Try not logged in" do
    it "should fail" do
      get :index, :version => 1
      
      expect(subject.current_user).to be_nil
      
      expect(response.status).to eq(404)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('error')).to be true
      expect(result['error_description']).to eq(I18n.t('auth_token_not_found'))
    end
  end

  describe "Try logged in" do
    it "should fail" do
      get :index, :version => 1, :auth_token => user.authentication_token
      
      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.currencies.count).to eq(2)
      
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?('error')).to be false
      expect(result.keys.include?('response')).to be true
      expect(result['response'].keys).to eq(subject.current_user.currencies.map { |c| c.name })
    end
  end
end
