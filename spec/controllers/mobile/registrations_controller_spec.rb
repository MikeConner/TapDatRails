require 'nickname_generator'

describe Mobile::V1::RegistrationsController, :type => :controller do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe "Try to create duplicate user (non-unique phone secret)" do
    let(:user) { FactoryGirl.create(:user) }
    
    before do
      Nickname.delete_all
      Nickname.create(:column => 1, :word => 'Dirk')
      Nickname.create(:column => 2, :word => 'QuadBlast')
      NicknameGenerator.reset
    end

    it "should fail" do
      post :create, :version => 1, :user => {:phone_secret_key => user.phone_secret_key}
      
      subject.current_user.should be_nil
      response.status.should be == 400
      
      result = JSON.parse(response.body)
      result.keys.include?("response").should be_false
      result.keys.include?("error").should be_true
      result["error_description"].should match('duplicate key value violates unique constraint')
    end
  end
  
  describe "Create regular user" do
    let(:email) { FactoryGirl.generate(:random_email) }
    let(:secret_key) { SecureRandom.hex(8) }
    let(:password) { SecureRandom.hex(16) }
    let(:nickname) { NicknameGenerator.generate_tough_guy }
    
    it "creates user successfully" do
      post :create, :version => 1, :user => {:email => email, :password => password, :nickname => nickname, :phone_secret_key => secret_key}
      
      subject.current_user.should_not be_nil
      subject.current_user.email.should be == email
      subject.current_user.name.should be == nickname
      subject.current_user.phone_secret_key.should be == secret_key
      subject.current_user.inbound_btc_address.should_not be_nil
      
      result = JSON.parse(response.body)
      result['response'].keys.include?('nickname').should be_true
      result['response']['nickname'].should be == nickname
      result['response']['auth_token'].should_not be_blank
      result.keys.include?('error').should be_false
    end
 
    describe "creates user successfully (minimal)" do
      before do
        Nickname.delete_all
        Nickname.create(:column => 1, :word => 'Ham')
        Nickname.create(:column => 2, :word => 'Fist')
        NicknameGenerator.reset
      end
      
      it "should succeed with nickname" do
        post :create, :version => 1, :user => {:phone_secret_key => secret_key}
        
        subject.current_user.should_not be_nil
        subject.current_user.email.should_not be_blank
        subject.current_user.name.should_not be_blank
        subject.current_user.phone_secret_key.should be == secret_key
        
        result = JSON.parse(response.body)
        result['response'].keys.include?('nickname').should be_true
        result['response']['nickname'].should be == "Ham Fist"
        result['response']['auth_token'].should_not be_blank
        result.keys.include?('error').should be_false
      end
    end

    describe "fails with user error" do
      before { NicknameGenerator.reset }
      
      it "has no nicknames" do
        post :create, :version => 1, :user => {:phone_secret_key => secret_key}
        
        subject.current_user.should be_nil
        response.status.should be == 400
        
        result = JSON.parse(response.body)
        result.keys.include?("response").should be_false
        result.keys.include?("error").should be_true
        result["error_description"].should be == I18n.t('no_generator')
      end
    end
    
    it "fails with no user" do
      post :create, :version => 1
      
      subject.current_user.should be_nil
      response.status.should be == 400
      
      result = JSON.parse(response.body)
      result.keys.include?("response").should be_false
      result.keys.include?("error").should be_true
      result["error_description"].should be == I18n.t('missing_argument', :arg => 'user')
    end

    it "fails with no key" do
      post :create, :version => 1, :user => { :email => email, :password => password, :nickname => nickname }
      
      subject.current_user.should be_nil
      response.status.should be == 400
      
      result = JSON.parse(response.body)
      result.keys.include?("response").should be_false
      result.keys.include?("error").should be_true
      result["error_description"].should be == I18n.t('missing_argument', :arg => 'phone secret key')
    end
  end
end
