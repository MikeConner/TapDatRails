describe Mobile::V1::UsersController, :type => :controller do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe "Cashout (insufficient)" do
    let(:user) { FactoryGirl.create(:user, :satoshi_balance => CoinbaseAPI::WITHDRAWAL_THRESHOLD / 2) }
    
    it "should fail for insufficient balance" do
      put :cashout, :version => 1, :auth_token => user.authentication_token

      subject.current_user.satoshi_balance.should be == CoinbaseAPI::WITHDRAWAL_THRESHOLD / 2
      response.status.should be == 400
      
      result = JSON.parse(response.body)
      result.keys.include?('response').should be_false
      result.keys.include?('error').should be_true
      result["error_description"].should be == I18n.t('insufficient_balance')            
    end
  end

 describe "Cashout (no inbound address)" do
    let(:user) { FactoryGirl.create(:user, :inbound_btc_address => nil, :satoshi_balance => CoinbaseAPI::WITHDRAWAL_THRESHOLD * 2) }
    
    it "should fail for no inbound address" do
      put :cashout, :version => 1, :auth_token => user.authentication_token

      subject.current_user.satoshi_balance.should be == CoinbaseAPI::WITHDRAWAL_THRESHOLD * 2
      subject.current_user.inbound_btc_address.should be_nil
      
      response.status.should be == 400
      
      result = JSON.parse(response.body)
      result.keys.include?('response').should be_false
      result.keys.include?('error').should be_true
      result["error_description"].should be == I18n.t('invalid_btc_addresses')            
    end
  end
  
 describe "Cashout (no outbound address)" do
    let(:user) { FactoryGirl.create(:user, :outbound_btc_address => nil, :satoshi_balance => CoinbaseAPI::WITHDRAWAL_THRESHOLD * 10) }
    
    it "should fail for no outbound address" do
      put :cashout, :version => 1, :auth_token => user.authentication_token

      subject.current_user.satoshi_balance.should be == CoinbaseAPI::WITHDRAWAL_THRESHOLD * 10
      subject.current_user.outbound_btc_address.should be_nil
      
      response.status.should be == 400
      
      result = JSON.parse(response.body)
      result.keys.include?('response').should be_false
      result.keys.include?('error').should be_true
      result["error_description"].should be == I18n.t('invalid_btc_addresses')            
    end
  end

 describe "Cashout" do
    let(:user) { FactoryGirl.create(:user, :satoshi_balance => CoinbaseAPI::WITHDRAWAL_THRESHOLD * 2) }
    
    it "should succeed" do
      put :cashout, :version => 1, :auth_token => user.authentication_token

      subject.current_user.satoshi_balance.should be == 0
      Transaction.count.should be == 1
      TransactionDetail.count.should be == 1
      subject.current_user.transactions.first.satoshi_amount.should be == CoinbaseAPI::WITHDRAWAL_THRESHOLD * 2
      
      response.status.should be == 200
      
      result = JSON.parse(response.body)
      result.keys.include?('response').should be_true
      result['response']['success'].should be_true
      result['response']['id'].should_not be_blank
      result['response'].keys.include?('data').should be_true
      result.keys.include?('error').should be_false
    end
  end
  
  describe "Balance inquiry (no address)" do
    let(:user) { FactoryGirl.create(:user, :inbound_btc_address => nil) }
    
    it "should fail" do
      get :balance_inquiry, :version => 1, :auth_token => user.authentication_token
            
      subject.current_user.inbound_btc_address.should be_nil
      response.status.should be == 404
      
      result = JSON.parse(response.body)
      result.keys.include?('response').should be_false
      result.keys.include?('error').should be_true
      result["error_description"].should be == I18n.t('no_btc_address')      
    end
  end

  describe "Balance inquiry" do
    let(:user) { FactoryGirl.create(:user) }
    
    before do
      CoinbaseAPI.any_instance.stub(:balance_inquiry).and_return(1.5)      
      CoinbaseAPI.any_instance.stub(:sell_price).and_return(450)      
    end
    
    it "should work" do
      get :balance_inquiry, :version => 1, :auth_token => user.authentication_token
            
      subject.current_user.inbound_btc_address.should be == user.inbound_btc_address
      response.status.should be == 200
      
      result = JSON.parse(response.body)
      result.keys.include?('response').should be_true
      result.keys.include?('error').should be_false
      result["response"]["btc_balance"].should be == 1.5      
      result["response"]["dollar_balance"].should be == 450      
      result["response"]["exchange_rate"].should be == 300      
    end
  end

  describe "Balance inquiry (invalid address)" do
    let(:user) { FactoryGirl.create(:user) }
    
    before do
      CoinbaseAPI.any_instance.stub(:balance_inquiry).and_return(nil)      
      CoinbaseAPI.any_instance.stub(:sell_price).and_return(300)      
    end
    
    it "should work" do
      get :balance_inquiry, :version => 1, :auth_token => user.authentication_token
            
      response.status.should be == 404
      
      result = JSON.parse(response.body)
      result.keys.include?('response').should be_false
      result.keys.include?('error').should be_true
      result["error_description"].should be == I18n.t('address_not_found')      
    end
  end

  describe "Balance inquiry (0 balance)" do
    let(:user) { FactoryGirl.create(:user) }
    
    before do
      CoinbaseAPI.any_instance.stub(:balance_inquiry).and_return(0)      
      CoinbaseAPI.any_instance.stub(:sell_price).and_return(0)      
    end
    
    it "should work" do
      get :balance_inquiry, :version => 1, :auth_token => user.authentication_token
            
      subject.current_user.inbound_btc_address.should be == user.inbound_btc_address
      response.status.should be == 200
      
      result = JSON.parse(response.body)
      result.keys.include?('response').should be_true
      result.keys.include?('error').should be_false
      result["response"]["btc_balance"].should be == 0      
      result["response"]["dollar_balance"].should be == 0      
      result["response"]["exchange_rate"].should be_nil      
    end
  end
  
  describe "Try with invalid token" do
    it "should fail" do
      get :show, :version => 1, :id => 0, :auth_token => SecureRandom.hex(16)

      subject.current_user.should be_nil

      response.status.should be == 404
      
      result = JSON.parse(response.body)
      result.keys.include?("response").should be_false
      result.keys.include?("error").should be_true
      result["error_description"].should be == I18n.t('auth_token_not_found')
    end
  end
  
  describe "User show" do
    let(:user) { FactoryGirl.create(:user) }
        
    it "creates session successfully" do
      get :show, :version => 1, :id => 0, :auth_token => user.authentication_token
      
      subject.current_user.should_not be_nil
      subject.current_user.email.should be == user.email
      subject.current_user.name.should be == user.name
      subject.current_user.inbound_btc_address.should be == user.inbound_btc_address
      subject.current_user.outbound_btc_address.should be == user.outbound_btc_address
      subject.current_user.satoshi_balance.should be == user.satoshi_balance
      subject.current_user.phone_secret_key.should be == user.phone_secret_key
      
      response.status.should be == 200
      
      result = JSON.parse(response.body)
      result['response'].keys.include?('nickname').should be_true
      result['response'].keys.include?('email').should be_true
      result['response'].keys.include?('inbound_btc_address').should be_true
      result['response'].keys.include?('outbound_btc_address').should be_true
      result['response'].keys.include?('satoshi_balance').should be_true
      result['response'].keys.include?('profile_image').should be_true
      result['response'].keys.include?('profile_thumb').should be_true
      result['response']['nickname'].should be == user.name
      result['response']['email'].should be == user.email
      result['response']['inbound_btc_address'].should be == user.inbound_btc_address
      result['response']['outbound_btc_address'].should be == user.outbound_btc_address
      result['response']['satoshi_balance'].should be == user.satoshi_balance
      result.keys.include?('error').should be_false
    end
  end  

  describe "User reset_nickname (without generator)" do
    let(:user) { FactoryGirl.create(:user) }
        
    before { NicknameGenerator.reset }
    
    it "creates session successfully" do
      put :reset_nickname, :version => 1, :auth_token => user.authentication_token
      
      subject.current_user.should_not be_nil
      subject.current_user.name.should_not be_blank
            
      response.status.should be == 400
      
      result = JSON.parse(response.body)
      result.keys.include?("response").should be_false
      result.keys.include?("error").should be_true
      result["error_description"].should be == I18n.t('no_generator')
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
      
      subject.current_user.should_not be_nil
      subject.current_user.name.should be == nickname
      subject.current_user.inbound_btc_address.should be == user.inbound_btc_address
      subject.current_user.inbound_btc_address.should_not be == inbound_btc_address
      subject.current_user.outbound_btc_address.should_not be == user.outbound_btc_address
      subject.current_user.outbound_btc_address.should be == outbound_btc_address
      subject.current_user.authentication_token.should be == user.authentication_token
      subject.current_user.authentication_token.should_not be == authentication_token
      subject.current_user.satoshi_balance.should be == user.satoshi_balance
      subject.current_user.satoshi_balance.should_not be == satoshi_balance
      subject.current_user.phone_secret_key.should be == user.phone_secret_key
      subject.current_user.phone_secret_key.should_not be == phone_secret_key
      subject.current_user.email.should_not be == user.email
      subject.current_user.email.should be == email
            
      response.status.should be == 200
      
      result = JSON.parse(response.body)
      result['response'].keys.include?('nickname').should be_true
      result['response']['nickname'].should_not be == @old_name
      result['response']['inbound_btc_address'].should be == user.inbound_btc_address
      result['response']['outbound_btc_address'].should be == outbound_btc_address
      result['response']['email'].should be == email
      result.keys.include?('error').should be_false
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
      
      subject.current_user.should_not be_nil
      subject.current_user.name.should_not be_blank
            
      response.status.should be == 200
      
      result = JSON.parse(response.body)
      result['response'].keys.include?('nickname').should be_true
      result['response']['nickname'].should_not be == @old_name
      result.keys.include?('error').should be_false
    end
  end    
end
