describe Mobile::V1::SessionsController, :type => :controller do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe "Login regular user" do
    let(:user) { FactoryGirl.create(:user) }
        
    it "creates session successfully" do
      post :create, :version => 1, :auth_token => user.authentication_token
      
      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.email).to eq(user.email)
      expect(subject.current_user.name).to eq(user.name)
      expect(subject.current_user.phone_secret_key).to eq(user.phone_secret_key)
      
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(result['response'].keys.include?('nickname')).to be true
      expect(result['response']['nickname']).to eq(user.name)
      expect(result.keys.include?('error')).to be false
    end
  
    describe "logout user" do
      before { sign_in user }
      
      it "should destroy the session" do
        expect(subject.current_user).to eq(user)
        
        delete :destroy, :version => 1, :id => user.id, :auth_token => user.authentication_token
      
        expect(subject.current_user).to be_nil
        expect(response.status).to eq(200)
      end
    end
  end
end
