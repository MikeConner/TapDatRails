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
      
      expect(subject.current_user).to be_nil
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?("response")).to be false
      expect(result.keys.include?("error")).to be true
      expect(result["error_description"]).to match('duplicate key value violates unique constraint')
    end
  end
  
  describe "Create regular user" do
    let(:email) { FactoryGirl.generate(:random_email) }
    let(:secret_key) { SecureRandom.hex(8) }
    let(:password) { SecureRandom.hex(16) }
    let(:nickname) { NicknameGenerator.generate_tough_guy }
    
    it "creates user successfully" do
      post :create, :version => 1, :user => {:email => email, :password => password, :nickname => nickname, :phone_secret_key => secret_key}
      
      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.email).to eq(email)
      expect(subject.current_user.name).to eq(nickname)
      expect(subject.current_user.phone_secret_key).to eq(secret_key)
      expect(subject.current_user.inbound_btc_address).to_not be_nil
      expect(subject.current_user.inbound_btc_qrcode).to_not be_nil
      
      result = JSON.parse(response.body)
      
      expect(result['response'].keys.include?('nickname')).to be true
      expect(result['response']['nickname']).to eq(nickname)
      expect(result['response']['auth_token']).to_not be_blank
      expect(result.keys.include?('error')).to be false
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
        
        expect(subject.current_user).to_not be_nil
        expect(subject.current_user.email).to_not be_blank
        expect(subject.current_user.name).to_not be_blank
        expect(subject.current_user.phone_secret_key).to eq(secret_key)
        
        result = JSON.parse(response.body)
        
        expect(result['response'].keys.include?('nickname')).to be true
        expect(result['response']['nickname']).to eq("Ham Fist")
        expect(result['response']['auth_token']).to_not be_blank
        expect(result.keys.include?('error')).to be false
      end
    end

    describe "fails with user error" do
      before { NicknameGenerator.reset }
      
      it "has no nicknames" do
        post :create, :version => 1, :user => {:phone_secret_key => secret_key}
        
        expect(subject.current_user).to be_nil
        expect(response.status).to eq(400)
        
        result = JSON.parse(response.body)
        
        expect(result.keys.include?("response")).to be false
        expect(result.keys.include?("error")).to be true
        expect(result["error_description"]).to eq(I18n.t('no_generator'))
        expect(result["user_error"]).to eq(I18n.t('invalid_registration'))
      end
    end
    
    it "fails with no user" do
      post :create, :version => 1
      
      expect(subject.current_user).to be_nil
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?("response")).to be false
      expect(result.keys.include?("error")).to be true
      expect(result["error_description"]).to eq(I18n.t('missing_argument', :arg => 'user'))
        expect(result["user_error"]).to eq(I18n.t('invalid_registration'))
    end

    it "fails with no key" do
      post :create, :version => 1, :user => { :email => email, :password => password, :nickname => nickname }
      
      expect(subject.current_user).to be_nil
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?("response")).to be false
      expect(result.keys.include?("error")).to be true
      expect(result["error_description"]).to eq(I18n.t('missing_argument', :arg => 'phone secret key'))
      expect(result["user_error"]).to eq(I18n.t('invalid_registration'))
    end
  end
end
