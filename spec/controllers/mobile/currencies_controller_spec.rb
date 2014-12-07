describe Mobile::V1::CurrenciesController, :type => :controller do
  let(:user) { FactoryGirl.create(:user_with_currencies) }

  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "Try not logged in" do
    it "should fail" do
      get :index, :version => 1
      
      subject.current_user.should be_nil
      
      response.status.should be == 404
      
      result = JSON.parse(response.body)
      result.keys.include?('error').should be_true
      result['error_description'].should be == I18n.t('auth_token_not_found')
    end
  end

  describe "Try logged in" do
    it "should fail" do
      get :index, :version => 1, :auth_token => user.authentication_token
      
      subject.current_user.should_not be_nil
      subject.current_user.currencies.count.should be == 2
      
      response.status.should be == 200
      
      result = JSON.parse(response.body)
      result.keys.include?('error').should be_false
      result.keys.include?('response').should be_true
      result['response'].keys.should be == subject.current_user.currencies.map { |c| c.name }
    end
  end
end
