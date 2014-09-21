describe Mobile::V1::SessionsController, :type => :controller do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe "Login regular user" do
    let(:user) { FactoryGirl.create(:user) }
        
    it "creates session successfully" do
      post :create, :version => 1, :auth_token => user.authentication_token
      
      subject.current_user.should_not be_nil
      subject.current_user.email.should be == user.email
      subject.current_user.name.should be == user.name
      subject.current_user.phone_secret_key.should be == user.phone_secret_key
      
      response.status.should be == 200
      
      result = JSON.parse(response.body)
      result['response'].keys.include?('nickname').should be_true
      result['response']['nickname'].should be == user.name
      result.keys.include?('error').should be_false
    end
  
    describe "logout user" do
      before { sign_in user }
      
      it "should destroy the session" do
        subject.current_user.should be == user
        
        delete :destroy, :version => 1, :id => user.id, :auth_token => user.authentication_token
      
        subject.current_user.should be_nil
        response.status.should be == 200
      end
    end
  end
end
