describe Mobile::V1::UsersController, :type => :controller do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "Redeem voucher" do
    let(:user) { FactoryGirl.create(:user) }
    let(:voucher) { FactoryGirl.create(:voucher) }
    # Will have issuer's user id
    let(:my_voucher) { FactoryGirl.create(:voucher) }
    let(:currency) { FactoryGirl.create(:currency_with_permanent_generator, :reserve_balance => 1000) }
    let(:redeemed_voucher) { FactoryGirl.create(:voucher, :status => Voucher::REDEEMED) }
      
    it "should not find invalid voucher" do
      put :redeem_voucher, :version => 1, :auth_token => user.authentication_token, :id => 83242
      
      expect(response.status).to eq(404)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq(I18n.t('voucher_not_found', :uid => 83242))         
      expect(result["user_error"]).to eq(I18n.t('redemption_error'))         
    end

    it "should find redeemed voucher" do
      put :redeem_voucher, :version => 1, :auth_token => user.authentication_token, :id => redeemed_voucher.uid
      
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq(I18n.t('inactive_voucher', :uid => redeemed_voucher.uid))         
      expect(result["user_error"]).to eq(I18n.t('redemption_error'))         
    end

    it "should find other user's voucher -- doesn't matter; they aren't owned until redeemed" do
      put :redeem_voucher, :version => 1, :auth_token => user.authentication_token, :id => voucher.uid
      
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?('response')).to be true
      expect(result.keys.include?('error')).to be false
      expect(result['response']['amount_redeemed']).to eq(voucher.amount)
      expect(result['response']['balance']).to eq(voucher.amount)
      expect(result['response'].keys.include?('currency')).to be true
      expect(Balance.count).to eq(1)
      
      expect(user.currency_balance(voucher.currency)).to eq(voucher.amount)
    end
   
    describe "Coupon redemption should fail if no reserve" do
      before { currency.update_attribute(:reserve_balance, 0)  }
      
      it "should have insufficient funds" do
        code = currency.single_code_generators.first.code
        expect(currency.reserve_balance).to eq(0)
        
        put :redeem_voucher, :version => 1, :auth_token => user.authentication_token, :id => code
        
        expect(response.status).to eq(400)
        
        result = JSON.parse(response.body)
        
        expect(result.keys.include?('response')).to be false
        expect(result.keys.include?('error')).to be true
        expect(result["error_description"]).to eq(I18n.t('insufficient_funds'))         
        expect(result["user_error"]).to eq(I18n.t('redemption_error'))         
      end
    end
  
    it "should redeem voucher" do
      put :redeem_voucher, :version => 1, :auth_token => user.authentication_token, :id => my_voucher.uid
      
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?('response')).to be true
      expect(result.keys.include?('error')).to be false
      expect(result['response'].keys.include?('currency')).to be true
      expect(result['response']['currency']['id']).to eq(my_voucher.currency.id)
      expect(result['response']['currency']['name']).to eq(my_voucher.currency.name)
      expect(result['response']['currency']['symbol']).to eq(my_voucher.currency.symbol)
      expect(result['response']['currency']['icon']).to eq(my_voucher.currency.icon.url)
      expect(result['response']['balance']).to eq(my_voucher.amount)
      expect(result['response']['amount_redeemed']).to eq(my_voucher.amount)
      expect(Balance.count).to eq(1)
      
      expect(user.currency_balance(my_voucher.currency)).to eq(my_voucher.amount)
      expect(user.transactions.first.voucher_id).to eq(my_voucher.id)
    end

    it "should redeem coupon voucher" do
      code = currency.single_code_generators.first.code
      
      put :redeem_voucher, :version => 1, :auth_token => user.authentication_token, :id => code
      
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(currency.reload.reserve_balance).to eq(1000 - currency.single_code_generators.first.value)
      expect(Transaction.find_by_comment(I18n.t('single_code_redemption', :code => code))).to_not be_nil
      expect(Transaction.find_by_comment('Voucher redemption').amount).to eq(currency.single_code_generators.first.value)
      
      expect(result.keys.include?('response')).to be true
      expect(result.keys.include?('error')).to be false
      expect(result['response'].keys.include?('currency')).to be true
      expect(result['response']['currency']['id']).to eq(currency.id)
      expect(result['response']['currency']['name']).to eq(currency.name)
      expect(result['response']['currency']['symbol']).to eq(currency.symbol)
      expect(result['response']['currency']['icon']).to eq(currency.icon.url)
      expect(result['response']['balance']).to eq(currency.single_code_generators.first.value)
      expect(result['response']['amount_redeemed']).to eq(currency.single_code_generators.first.value)
      expect(Balance.count).to eq(1)
      
      expect(user.currency_balance(currency)).to eq(currency.single_code_generators.first.value)
      expect(user.transactions.first.voucher_id).to eq(Voucher.first.id)
      expect(user.vouchers.count).to eq(1)
      
      # try to redeem again
      put :redeem_voucher, :version => 1, :auth_token => user.authentication_token, :id => code
      
      expect(response.status).to eq(400)

      result = JSON.parse(response.body)
      
      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq(I18n.t('already_redeemed_voucher'))         
      expect(result["user_error"]).to eq(I18n.t('redemption_error'))         
    end
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
      expect(result["error_description"]).to eq(I18n.t('insufficient_funds'))         
      expect(result["user_error"]).to eq(I18n.t('cashout_error'))            
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
      expect(result["user_error"]).to eq(I18n.t('cashout_error'))            
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
      expect(result["user_error"]).to eq(I18n.t('cashout_error'))            
    end
  end

 describe "Cashout" do
    let(:user) { FactoryGirl.create(:user, :satoshi_balance => CoinbaseAPI::WITHDRAWAL_THRESHOLD * 2) }
    
    it "should succeed" do
      put :cashout, :version => 1, :auth_token => user.authentication_token

      expect(subject.current_user.satoshi_balance).to eq(0)
      expect(Transaction.count).to eq(1)
      expect(TransactionDetail.count).to eq(1)
      expect(subject.current_user.transactions.first.amount).to eq(CoinbaseAPI::WITHDRAWAL_THRESHOLD * 2)
      
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?('response')).to be true
      expect(result['response']['success']).to be true
      expect(result['response']['id']).to_not be_blank
      expect(result['response'].keys.include?('data')).to be true
      expect(result.keys.include?('error')).to be false
    end
  end

  describe "Balance inquiry (currencies)" do
    let(:user) { FactoryGirl.create(:user_with_balances) }
    
    before do
      allow_any_instance_of(CoinbaseAPI).to receive(:balance_inquiry).and_return(1.5)      
      allow_any_instance_of(CoinbaseAPI).to receive(:sell_price).and_return(450)      
    end

    it "should return them" do
      get :balance_inquiry, :version => 1, :auth_token => user.authentication_token
            
      expect(subject.current_user.inbound_btc_address).to eq(user.inbound_btc_address)
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?('response')).to be true
      expect(result.keys.include?('error')).to be false
      expect(result["response"]["btc_balance"]).to eq(1.5)      
      expect(result["response"]["dollar_balance"]).to eq(450)      
      expect(result["response"]["exchange_rate"]).to eq(300)    
      expect(result["response"]["balances"].count).to eq(2) 
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
      expect(result["user_error"]).to eq(I18n.t('invalid_bitcoin_addr'))      
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
      expect(result["error_description"]).to match(I18n.t('address_not_found'))      
      expect(result["user_error"]).to eq(I18n.t('invalid_bitcoin_addr'))      
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

  describe "Balance inquiry (test mode)" do
    let(:user) { FactoryGirl.create(:user) }
    
    before do
      allow_any_instance_of(CoinbaseAPI).to receive(:balance_inquiry).and_return(408000)      
      allow_any_instance_of(CoinbaseAPI).to receive(:sell_price).and_return(102.5)      
    end
     
    it "should work" do
      get :balance_inquiry, :version => 1, :auth_token => user.authentication_token
            
      expect(subject.current_user.inbound_btc_address).to eq(user.inbound_btc_address)
      expect(subject.current_user.reload.satoshi_balance).to eq(408000)
      
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(result.keys.include?('response')).to be true
      expect(result.keys.include?('error')).to be false
      expect(result["response"]["btc_balance"]).to eq(408000)      
      expect(result["response"]["dollar_balance"]).to eq(102.5)      
      expect(result["response"]["exchange_rate"]).to_not be_nil      
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
      expect(result["user_error"]).to be_nil
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
      expect(result["user_error"]).to eq(I18n.t('nickname_reset_error'))
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
    
    it "Blank email and profile test" do
       put :update, :version => 1, :id => "me", :auth_token => user.authentication_token, 
                    :user => {:email => "", 
                              :name => nickname,
                              :mobile_profile_thumb_url => "https://tapyapa.s3.amazonaws.com/58132089-be91-4be4-8fcc-5aec6efef220"}
      
      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.name).to eq(nickname)
      expect(subject.current_user.mobile_profile_thumb_url).to eq("https://tapyapa.s3.amazonaws.com/58132089-be91-4be4-8fcc-5aec6efef220")
            
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(result['response'].keys.include?('nickname')).to be true
      expect(result['response']['nickname']).to_not eq(@old_name)
      expect(result['response']['inbound_btc_address']).to eq(user.inbound_btc_address)
      expect(result['response']['email']).to eq(user.email)
      expect(result.keys.include?('error')).to be false
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
