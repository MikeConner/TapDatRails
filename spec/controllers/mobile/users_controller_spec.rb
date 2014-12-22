describe Mobile::V1::UsersController, :type => :controller do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe "Cashout (insufficient)" do
    let(:user) { FactoryGirl.create(:user, :satoshi_balance => CoinbaseAPI::WITHDRAWAL_THRESHOLD / 2) }
    
    it "should fail for insufficient balance" do
      put :cashout, :version => 1, :auth_token => user.authentication_token

      expect(subject.current_user.satoshi_balance).to eq(CoinbaseAPI::WITHDRAWAL_THRESHOLD / 2)
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq(I18n.t('insufficient_balance'))         
    end
  end

 describe "Cashout (no inbound address)" do
    let(:user) { FactoryGirl.create(:user, :inbound_btc_address => nil, :satoshi_balance => CoinbaseAPI::WITHDRAWAL_THRESHOLD * 2) }
    
    it "should fail for no inbound address" do
      put :cashout, :version => 1, :auth_token => user.authentication_token

      expect(subject.current_user.satoshi_balance).to eq(CoinbaseAPI::WITHDRAWAL_THRESHOLD * 2)
      expect(subject.current_user.inbound_btc_address).to be_nil
      
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq(I18n.t('invalid_btc_addresses'))            
    end
  end
  
 describe "Cashout (no outbound address)" do
    let(:user) { FactoryGirl.create(:user, :outbound_btc_address => nil, :satoshi_balance => CoinbaseAPI::WITHDRAWAL_THRESHOLD * 10) }
    
    it "should fail for no outbound address" do
      put :cashout, :version => 1, :auth_token => user.authentication_token

      expect(subject.current_user.satoshi_balance).to eq(CoinbaseAPI::WITHDRAWAL_THRESHOLD * 10)
      expect(subject.current_user.outbound_btc_address).to be_nil
      
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq(I18n.t('invalid_btc_addresses'))            
    end
  end

 describe "Cashout" do
    let(:user) { FactoryGirl.create(:user, :satoshi_balance => CoinbaseAPI::WITHDRAWAL_THRESHOLD * 2) }
    
    it "should succeed" do
      put :cashout, :version => 1, :auth_token => user.authentication_token

      expect(subject.current_user.satoshi_balance).to eq(0)
      expect(Transaction.count).to eq(1)
      expect(TransactionDetail.count).to eq(1)
      expect(subject.current_user.transactions.first.satoshi_amount).to eq(CoinbaseAPI::WITHDRAWAL_THRESHOLD * 2)
      
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?('response')).to be true
      expect(result['response']['success']).to be true
      expect(result['response']['id']).to_not be_blank
      expect(result['response'].keys.include?('data')).to be true
      expect(result.keys.include?('error')).to be false
    end
  end
  
  describe "Balance inquiry (no address)" do
    let(:user) { FactoryGirl.create(:user, :inbound_btc_address => nil) }
    
    it "should fail" do
      get :balance_inquiry, :version => 1, :auth_token => user.authentication_token
            
      expect(subject.current_user.inbound_btc_address).to be_nil
      expect(response.status).to eq(404)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq(I18n.t('no_btc_address'))      
    end
  end

  describe "Balance inquiry" do
    let(:user) { FactoryGirl.create(:user) }
    
    before do
      allow_any_instance_of(CoinbaseAPI).to receive(:balance_inquiry).and_return(1.5)      
      allow_any_instance_of(CoinbaseAPI).to receive(:sell_price).and_return(450)      
    end
    
    it "should work" do
      get :balance_inquiry, :version => 1, :auth_token => user.authentication_token
            
      expect(subject.current_user.inbound_btc_address).to eq(user.inbound_btc_address)
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?('response')).to be true
      expect(result.keys.include?('error')).to be false
      expect(result["response"]["btc_balance"]).to eq(1.5)      
      expect(result["response"]["dollar_balance"]).to eq(450)      
      expect(result["response"]["exchange_rate"]).to eq(300)      
    end
  end

  describe "Balance inquiry (invalid address)" do
    let(:user) { FactoryGirl.create(:user) }
    
    before do
      allow_any_instance_of(CoinbaseAPI).to receive(:balance_inquiry).and_return(nil)      
      allow_any_instance_of(CoinbaseAPI).to receive(:sell_price).and_return(300)      
    end
    
    it "should work" do
      get :balance_inquiry, :version => 1, :auth_token => user.authentication_token
            
      expect(response.status).to eq(404)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq(I18n.t('address_not_found'))      
    end
  end

  describe "Balance inquiry (0 balance)" do
    let(:user) { FactoryGirl.create(:user) }
    
    before do
      allow_any_instance_of(CoinbaseAPI).to receive(:balance_inquiry).and_return(0)      
      allow_any_instance_of(CoinbaseAPI).to receive(:sell_price).and_return(0)      
    end
    
    it "should work" do
      get :balance_inquiry, :version => 1, :auth_token => user.authentication_token
            
      expect(subject.current_user.inbound_btc_address).to eq(user.inbound_btc_address)
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?('response')).to be true
      expect(result.keys.include?('error')).to be false
      expect(result["response"]["btc_balance"]).to eq(0)      
      expect(result["response"]["dollar_balance"]).to eq(0)      
      expect(result["response"]["exchange_rate"]).to be_nil      
    end
  end
  
  describe "Try with invalid token" do
    it "should fail" do
      get :show, :version => 1, :id => 0, :auth_token => SecureRandom.hex(16)

      expect(subject.current_user).to be_nil

      expect(response.status).to eq(404)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?("response")).to be false
      expect(result.keys.include?("error")).to be true
      expect(result["error_description"]).to eq(I18n.t('auth_token_not_found'))
    end
  end
  
  describe "User show" do
    let(:user) { FactoryGirl.create(:user) }
        
    it "creates session successfully" do
      get :show, :version => 1, :id => 0, :auth_token => user.authentication_token
      
      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.email).to eq(user.email)
      expect(subject.current_user.name).to eq(user.name)
      expect(subject.current_user.inbound_btc_address).to eq(user.inbound_btc_address)
      expect(subject.current_user.outbound_btc_address).to eq(user.outbound_btc_address)
      expect(subject.current_user.satoshi_balance).to eq(user.satoshi_balance)
      expect(subject.current_user.phone_secret_key).to eq(user.phone_secret_key)
      
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(result['response'].keys.include?('nickname')).to be true
      expect(result['response'].keys.include?('email')).to be true
      expect(result['response'].keys.include?('inbound_btc_address')).to be true
      expect(result['response'].keys.include?('outbound_btc_address')).to be true
      expect(result['response'].keys.include?('satoshi_balance')).to be true
      expect(result['response'].keys.include?('profile_image')).to be true
      expect(result['response'].keys.include?('profile_thumb')).to be true
      expect(result['response']['nickname']).to eq(user.name)
      expect(result['response']['email']).to eq(user.email)
      expect(result['response']['inbound_btc_address']).to eq(user.inbound_btc_address)
      expect(result['response']['outbound_btc_address']).to eq(user.outbound_btc_address)
      expect(result['response']['satoshi_balance']).to eq(user.satoshi_balance)
      expect(result.keys.include?('error')).to be false
    end
  end  

  describe "User reset_nickname (without generator)" do
    let(:user) { FactoryGirl.create(:user) }
        
    before { NicknameGenerator.reset }
    
    it "creates session successfully" do
      put :reset_nickname, :version => 1, :auth_token => user.authentication_token
      
      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.name).to_not be_blank
            
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?("response")).to be false
      expect(result.keys.include?("error")).to be true
      expect(result["error_description"]).to eq(I18n.t('no_generator'))
    end
  end  

  describe "User update" do
    let(:user) { FactoryGirl.create(:user) }
    let(:email) { FactoryGirl.generate(:random_email) }
    let(:nickname) { NicknameGenerator.generate_tough_guy }
    let(:inbound_btc_address) { FactoryGirl.generate(:random_bitcoin_address) }
    let(:outbound_btc_address) { FactoryGirl.generate(:random_bitcoin_address) }
    let(:satoshi_balance) { 500000000 }
    let(:authentication_token) { SecureRandom.hex(16) }
    let(:phone_secret_key) { SecureRandom.hex(8) }
    
    before do
      @old_name = user.name
      Nickname.create(:column => 1, :word => 'Blake')
      Nickname.create(:column => 2, :word => 'SlamFist')
    end
    
    it "updates user successfully" do
       put :update, :version => 1, :id => 0, :auth_token => user.authentication_token, 
                    :user => {:email => email, 
                              :name => nickname,
                              :inbound_btc_address => inbound_btc_address,
                              :outbound_btc_address => outbound_btc_address,
                              :satoshi_balance => satoshi_balance,
                              :authentication_token => authentication_token,
                              :phone_secret_key => phone_secret_key}
      
      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.name).to eq(nickname)
      expect(subject.current_user.inbound_btc_address).to eq(user.inbound_btc_address)
      expect(subject.current_user.inbound_btc_address).to_not eq(inbound_btc_address)
      expect(subject.current_user.outbound_btc_address).to_not eq(user.outbound_btc_address)
      expect(subject.current_user.outbound_btc_address).to eq(outbound_btc_address)
      expect(subject.current_user.authentication_token).to eq(user.authentication_token)
      expect(subject.current_user.authentication_token).to_not eq(authentication_token)
      expect(subject.current_user.satoshi_balance).to eq(user.satoshi_balance)
      expect(subject.current_user.satoshi_balance).to_not eq(satoshi_balance)
      expect(subject.current_user.phone_secret_key).to eq(user.phone_secret_key)
      expect(subject.current_user.phone_secret_key).to_not eq(phone_secret_key)
      expect(subject.current_user.email).to_not eq(user.email)
      expect(subject.current_user.email).to eq(email)
            
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(result['response'].keys.include?('nickname')).to be true
      expect(result['response']['nickname']).to_not eq(@old_name)
      expect(result['response']['inbound_btc_address']).to eq(user.inbound_btc_address)
      expect(result['response']['outbound_btc_address']).to eq(outbound_btc_address)
      expect(result['response']['email']).to eq(email)
      expect(result.keys.include?('error')).to be false
    end
  end  

  describe "User reset_nickname" do
    let(:user) { FactoryGirl.create(:user) }
        
    before do
      @old_name = user.name
      Nickname.create(:column => 1, :word => 'Dirk')
      Nickname.create(:column => 2, :word => 'QuadBlast')
    end
    
    it "creates session successfully" do
      put :reset_nickname, :version => 1, :auth_token => user.authentication_token
      
      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.name).to_not be_blank
            
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(result['response'].keys.include?('nickname')).to be true
      expect(result['response']['nickname']).to_not eq(@old_name)
      expect(result.keys.include?('error')).to be false
    end
  end    
end
