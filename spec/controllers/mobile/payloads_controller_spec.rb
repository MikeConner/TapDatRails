describe Mobile::V1::PayloadsController, :type => :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:nfc_tag) { FactoryGirl.create(:nfc_tag_with_payloads, :user => user) }
  
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "List payloads" do
    it "should work" do
      get :index, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token
      
      subject.current_user.should_not be_nil
      subject.current_user.nfc_tags.count.should be == 1
      tag = subject.current_user.nfc_tags.first
      tag.payloads.count.should be == 3
      
      response.status.should be == 200
      
      result = JSON.parse(response.body)

      result.keys.include?('response').should be_true 
      result['response'].each do |r|
        r.should_not be_blank
      end
      result['count'].should be == 3
      result.keys.include?('error').should be_false
    end
  end

  describe "Show payload" do
    it "should work" do
      get :show, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, :id => nfc_tag.payloads.first.id

      subject.current_user.should_not be_nil
      subject.current_user.nfc_tags.count.should be == 1
      tag = subject.current_user.nfc_tags.first
      tag.payloads.count.should be == 3
      
      response.status.should be == 200
      
      result = JSON.parse(response.body)

      result.keys.include?('response').should be_true
      result['response']['uri'].should_not be_blank
      result['response']['text'].should_not be_blank
      result['response']['threshold'].should_not be_blank       
      result.keys.include?('error').should be_false
    end

    it "should fail with invalid id" do
      get :show, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, :id => 0

      subject.current_user.should_not be_nil
      subject.current_user.nfc_tags.count.should be == 1
      tag = subject.current_user.nfc_tags.first
      tag.payloads.count.should be == 3
      
      response.status.should be == 404
      
      result = JSON.parse(response.body)

      result.keys.include?('response').should be_false
      result.keys.include?('error').should be_true
      result['error_description'].should be == I18n.t('object_not_found', :obj => 'Payload')
    end
  end
  
  describe "Create payload" do
    let(:nfc_tag) { FactoryGirl.create(:nfc_tag, :user => user) }
    let(:payload) { FactoryGirl.create(:payload) }
    
    it "should work" do      
      post :create, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, 
           :payload => {:uri => payload.uri, :content => payload.content, :threshold => payload.threshold}

      subject.current_user.should_not be_nil
      subject.current_user.nfc_tags.count.should be == 1
      tag = subject.current_user.nfc_tags.first
      tag.payloads.count.should be == 1
      
      response.status.should be == 200
      
      result = JSON.parse(response.body)

      result.keys.include?('response').should be_true
      result['response'].should_not be_blank
      result.keys.include?('error').should be_false
    end

    it "should fail if params invalid" do      
      post :create, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, 
           :payload => {:uri => payload.uri, :content => payload.content, :threshold => -2}

      subject.current_user.should_not be_nil
      subject.current_user.nfc_tags.count.should be == 1
      tag = subject.current_user.nfc_tags.first
      tag.payloads.count.should be == 0
      
      response.status.should be == 400
      
      result = JSON.parse(response.body)

      result.keys.include?('response').should be_false
      result.keys.include?('error').should be_true
      result['error_description'].should be == "Threshold must be greater than or equal to 0"
    end
  end

  describe "Update payload" do
    let(:new_payload) { FactoryGirl.create(:payload) }
    
    it "should work" do   
      payload = nfc_tag.payloads.last
      @new_threshold = payload.threshold * 2
         
      put :update, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, :id => payload.id,
          :payload => {:uri => new_payload.uri, :content => new_payload.content, :threshold => @new_threshold}

      subject.current_user.should_not be_nil
      subject.current_user.nfc_tags.count.should be == 1
      tag = subject.current_user.nfc_tags.first
      tag.payloads.count.should be == 3
      
      payload.reload.uri.should be == new_payload.uri
      payload.reload.content.should be == new_payload.content
      payload.reload.threshold.should be == @new_threshold
      response.status.should be == 200      
    end

    it "should fail if not found" do      
      payload = nfc_tag.payloads.last
      @new_threshold = payload.threshold * 2

      put :update, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, :id => 0,
          :payload => {:uri => new_payload.uri, :content => new_payload.content, :threshold => @new_threshold}

      subject.current_user.should_not be_nil
      subject.current_user.nfc_tags.count.should be == 1
      tag = subject.current_user.nfc_tags.first
      tag.payloads.count.should be == 3
      
      response.status.should be == 404
      
      result = JSON.parse(response.body)

      result.keys.include?('response').should be_false
      result.keys.include?('error').should be_true
      result['error_description'].should be == I18n.t('object_not_found', :obj => 'Payload')
    end

    it "should fail if params invalid" do      
      payload = nfc_tag.payloads.last
      @new_threshold = payload.threshold * 2

      put :update, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, :id => payload.id,
          :payload => {:uri => new_payload.uri, :content => new_payload.content, :threshold => -2}

      subject.current_user.should_not be_nil
      subject.current_user.nfc_tags.count.should be == 1
      tag = subject.current_user.nfc_tags.first
      tag.payloads.count.should be == 3
      
      response.status.should be == 400
      
      result = JSON.parse(response.body)

      result.keys.include?('response').should be_false
      result.keys.include?('error').should be_true
      result['error_description'].should be == "Validation failed: Threshold must be greater than or equal to 0"
    end
  end

  describe "Destroy payload" do
    it "should work" do   
      payload = nfc_tag.payloads.last
      
      delete :destroy, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, :id => payload.id

      subject.current_user.should_not be_nil
      subject.current_user.nfc_tags.count.should be == 1
      tag = subject.current_user.nfc_tags.first
      tag.payloads.count.should be == 2
      
      response.status.should be == 200      
    end
    
    it "should fail if not found" do      
      delete :destroy, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, :id => 0

      subject.current_user.should_not be_nil
      subject.current_user.nfc_tags.count.should be == 1
      tag = subject.current_user.nfc_tags.first
      tag.payloads.count.should be == 3
      
      response.status.should be == 404
      
      result = JSON.parse(response.body)

      result.keys.include?('response').should be_false
      result.keys.include?('error').should be_true
      result['error_description'].should be == I18n.t('object_not_found', :obj => 'Payload')
    end
  end
end
