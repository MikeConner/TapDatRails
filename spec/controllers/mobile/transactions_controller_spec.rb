describe Mobile::V1::TransactionsController, :type => :controller do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe "Do a tap" do
    INITIAL_AMOUNT = 10000000
    
    let(:user) { FactoryGirl.create(:user, :satoshi_balance => INITIAL_AMOUNT) }
    let(:stripper) { FactoryGirl.create(:user, :satoshi_balance => INITIAL_AMOUNT) }
    let(:tag) { FactoryGirl.create(:nfc_tag_with_payloads, :user => stripper, :name => 'Default') }
        
    it "should create a transaction" do
      post :create, :version => 1, :tag_id => tag.tag_id, :auth_token => user.authentication_token, :amount => 20
      
      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.transactions.count).to eq(1)
      expect(subject.current_user.transaction_details.count).to eq(2)
      
      tx = subject.current_user.transactions.first
      
      expect(tx.nfc_tag_id).to eq(tag.id)
      expect(tx.payload_id).to_not be_nil
      expect(tx.dollar_amount).to eq(2000)
      expect(tx.satoshi_amount).to eq((tx.transaction_details.first.conversion_rate * tx.dollar_amount * 1000000.0).round)
      expect(tx.comment).to eq(tx.payload.content)
      expect(subject.current_user.reload.satoshi_balance).to eq(INITIAL_AMOUNT - tx.satoshi_amount)
      expect(tag.user.reload.satoshi_balance).to eq(INITIAL_AMOUNT + tx.satoshi_amount)
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)

      expect(result['response'].keys.include?('payload')).to be true
      expect(result['response']['satoshi_amount']).to eq(INITIAL_AMOUNT - subject.current_user.reload.satoshi_balance)
      expect(result['response']['dollar_amount']).to eq(tx.dollar_amount)
      expect(result['response']['final_balance']).to eq(subject.current_user.reload.satoshi_balance)
      expect(result['response']['tapped_user_thumb']).to_not be_nil
      expect(result['response']['tapped_user_name']).to eq(stripper.name)
      expect(result['response']['payload']['text']).to eq(tx.payload.content)
      expect(result['response']['payload'].keys.include?('image')).to be true
      expect(result['response']['payload'].keys.include?('thumb')).to be true
      expect(result['response']['payload'].keys.include?('uri')).to be true
      expect(result.keys.include?('error')).to be false
    end

    it "missing tag_id" do
      post :create, :version => 1, :auth_token => user.authentication_token, :amount => 20
      
      expect(subject.current_user).to_not be_nil
      expect(Transaction.count).to eq(0)
      
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq(I18n.t('missing_argument', :arg => 'tag_id'))
    end

    it "missing amount" do
      post :create, :version => 1, :tag_id => tag.tag_id, :auth_token => user.authentication_token
      
      expect(subject.current_user).to_not be_nil
      expect(Transaction.count).to eq(0)
      
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq(I18n.t('missing_argument', :arg => 'amount'))
    end

    it "invalid amount" do
      post :create, :version => 1, :tag_id => tag.tag_id, :auth_token => user.authentication_token, :amount => 0
      
      expect(subject.current_user).to_not be_nil
      expect(Transaction.count).to eq(0)
      
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq(I18n.t('invalid_amount'))
    end

    it "rate not found" do
      allow_any_instance_of(BitcoinTicker).to receive(:current_rate).and_return(nil)
      
      post :create, :version => 1, :tag_id => tag.tag_id, :auth_token => user.authentication_token, :amount => 20
      
      expect(subject.current_user).to_not be_nil
      expect(Transaction.count).to eq(0)
      
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq(I18n.t('rate_not_found'))
    end

    it "Ticker inaccessible" do
      allow_any_instance_of(BitcoinTicker).to receive(:current_rate).and_return(nil)
      
      post :create, :version => 1, :tag_id => 'Invalid tag', :auth_token => user.authentication_token, :amount => 20
      
      expect(subject.current_user).to_not be_nil
      expect(Transaction.count).to eq(0)
      
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq(I18n.t('rate_not_found'))
    end

    describe "payload not found" do
      let(:tag) { FactoryGirl.create(:nfc_tag) }
      
      it "should fail" do
        post :create, :version => 1, :tag_id => tag.tag_id, :auth_token => user.authentication_token, :amount => 20
        
        expect(subject.current_user).to_not be_nil
        expect(Transaction.count).to eq(0)
        
        expect(response.status).to eq(404)
        
        result = JSON.parse(response.body)
  
        expect(result.keys.include?('response')).to be false
        expect(result.keys.include?('error')).to be true
        expect(result["error_description"]).to eq(I18n.t('object_not_found', :obj => 'Payload'))
      end
    end

    it "insufficient funds" do
      post :create, :version => 1, :tag_id => tag.tag_id, :auth_token => user.authentication_token, :amount => 2000
      
      expect(subject.current_user).to_not be_nil
      expect(Transaction.count).to eq(0)
      
      expect(response.status).to eq(403)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq(I18n.t('insufficient_funds'))
    end
  end
end
