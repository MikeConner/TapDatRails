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
      
      subject.current_user.should_not be_nil
      subject.current_user.transactions.count.should be == 1
      subject.current_user.transaction_details.count.should be == 2
      tx = subject.current_user.transactions.first
      tx.nfc_tag_id.should be == tag.id
      tx.payload_id.should_not be_nil
      tx.dollar_amount.should be == 2000
      tx.satoshi_amount.should be == (tx.transaction_details.first.conversion_rate * tx.dollar_amount * 1000000.0).round
      tx.comment.should be == tx.payload.content
      subject.current_user.reload.satoshi_balance.should be == INITIAL_AMOUNT - tx.satoshi_amount
      tag.user.reload.satoshi_balance.should be == INITIAL_AMOUNT + tx.satoshi_amount
      response.status.should be == 200
      
      result = JSON.parse(response.body)

      result['response'].keys.include?('payload').should be_true
      result['response']['satoshi_amount'].should be == INITIAL_AMOUNT - subject.current_user.reload.satoshi_balance
      result['response']['dollar_amount'].should be == tx.dollar_amount
      result['response']['final_balance'].should be == subject.current_user.reload.satoshi_balance
      result['response']['tapped_user_thumb'].should_not be_nil
      result['response']['tapped_user_name'].should be == stripper.name
      result['response']['payload']['text'].should be == tx.payload.content
      result['response']['payload'].keys.include?('image').should be_true
      result['response']['payload'].keys.include?('thumb').should be_true
      result['response']['payload'].keys.include?('uri').should be_true
      result.keys.include?('error').should be_false
    end

    it "missing tag_id" do
      post :create, :version => 1, :auth_token => user.authentication_token, :amount => 20
      
      subject.current_user.should_not be_nil
      Transaction.count.should be == 0
      
      response.status.should be == 400
      
      result = JSON.parse(response.body)

      result.keys.include?('response').should be_false
      result.keys.include?('error').should be_true
      result["error_description"].should be == I18n.t('missing_argument', :arg => 'tag_id')
    end

    it "missing amount" do
      post :create, :version => 1, :tag_id => tag.tag_id, :auth_token => user.authentication_token
      
      subject.current_user.should_not be_nil
      Transaction.count.should be == 0
      
      response.status.should be == 400
      
      result = JSON.parse(response.body)

      result.keys.include?('response').should be_false
      result.keys.include?('error').should be_true
      result["error_description"].should be == I18n.t('missing_argument', :arg => 'amount')
    end

    it "invalid amount" do
      post :create, :version => 1, :tag_id => tag.tag_id, :auth_token => user.authentication_token, :amount => 0
      
      subject.current_user.should_not be_nil
      Transaction.count.should be == 0
      
      response.status.should be == 400
      
      result = JSON.parse(response.body)

      result.keys.include?('response').should be_false
      result.keys.include?('error').should be_true
      result["error_description"].should be == I18n.t('invalid_amount')
    end

    it "rate not found" do
      BitcoinTicker.any_instance.stub(:current_rate).and_return(nil)
      
      post :create, :version => 1, :tag_id => tag.tag_id, :auth_token => user.authentication_token, :amount => 20
      
      subject.current_user.should_not be_nil
      Transaction.count.should be == 0
      
      response.status.should be == 400
      
      result = JSON.parse(response.body)

      result.keys.include?('response').should be_false
      result.keys.include?('error').should be_true
      result["error_description"].should be == I18n.t('rate_not_found')
    end

    it "Ticker inaccessible" do
      BitcoinTicker.any_instance.stub(:current_rate).and_return(nil)
      
      post :create, :version => 1, :tag_id => 'Invalid tag', :auth_token => user.authentication_token, :amount => 20
      
      subject.current_user.should_not be_nil
      Transaction.count.should be == 0
      
      response.status.should be == 400
      
      result = JSON.parse(response.body)

      result.keys.include?('response').should be_false
      result.keys.include?('error').should be_true
      result["error_description"].should be == I18n.t('rate_not_found')
    end

    describe "payload not found" do
      let(:tag) { FactoryGirl.create(:nfc_tag) }
      
      it "should fail" do
        post :create, :version => 1, :tag_id => tag.tag_id, :auth_token => user.authentication_token, :amount => 20
        
        subject.current_user.should_not be_nil
        Transaction.count.should be == 0
        
        response.status.should be == 404
        
        result = JSON.parse(response.body)
  
        result.keys.include?('response').should be_false
        result.keys.include?('error').should be_true
        result["error_description"].should be == I18n.t('object_not_found', :obj => 'Payload')
      end
    end

    it "insufficient funds" do
      post :create, :version => 1, :tag_id => tag.tag_id, :auth_token => user.authentication_token, :amount => 2000
      
      subject.current_user.should_not be_nil
      Transaction.count.should be == 0
      
      response.status.should be == 403
      
      result = JSON.parse(response.body)

      result.keys.include?('response').should be_false
      result.keys.include?('error').should be_true
      result["error_description"].should be == I18n.t('insufficient_funds')
    end
  end
end
