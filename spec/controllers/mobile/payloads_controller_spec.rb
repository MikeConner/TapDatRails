describe Mobile::V1::PayloadsController, :type => :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:nfc_tag) { FactoryGirl.create(:nfc_tag_with_payloads, :user => user) }
  
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "List payloads" do
    it "should work" do
      get :index, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token
      
      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.nfc_tags.count).to eq(1)
      
      tag = subject.current_user.nfc_tags.first
      expect(tag.payloads.count).to eq(3)
      
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be true 
      result['response'].each do |r|
        expect(r).to_not be_blank
      end
      
      expect(result['count']).to eq(3)
      expect(result.keys.include?('error')).to be false
    end
  end

  describe "Show payload" do
    it "should work" do
      get :show, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, :id => nfc_tag.payloads.first.id

      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.nfc_tags.count).to eq(1)
      
      tag = subject.current_user.nfc_tags.first
      expect(tag.payloads.count).to eq(3)
      
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be true
      expect(result['response']['uri']).to_not be_blank
      expect(result['response']['text']).to_not be_blank
      expect(Payload::VALID_CONTENT_TYPES.include?(result['response']['content_type'])).to be true
      expect(result['response']['threshold']).to_not be_blank       
      expect(result.keys.include?('error')).to be false
    end

    it "should fail with invalid id" do
      get :show, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, :id => 0

      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.nfc_tags.count).to eq(1)
      
      tag = subject.current_user.nfc_tags.first
      expect(tag.payloads.count).to eq(3)
      
      expect(response.status).to eq(404)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result['error_description']).to eq(I18n.t('object_not_found', :obj => 'Payload'))
    end
  end
  
  describe "Create payload" do
    let(:nfc_tag) { FactoryGirl.create(:nfc_tag, :user => user) }
    let(:payload) { FactoryGirl.create(:payload) }
    
    it "should work" do      
      post :create, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, 
           :payload => {:uri => payload.uri, :content => payload.content, :threshold => payload.threshold}

      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.nfc_tags.count).to eq(1)
      
      tag = subject.current_user.nfc_tags.first
      expect(tag.payloads.count).to eq(1)
      
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be true
      expect(result['response']).to_not be_blank
      expect(result.keys.include?('error')).to be false
    end

    it "should fail if params invalid" do      
      post :create, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, 
           :payload => {:uri => payload.uri, :content => payload.content, :threshold => -2}

      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.nfc_tags.count).to eq(1)
      
      tag = subject.current_user.nfc_tags.first
      expect(tag.payloads.count).to eq(0)
      
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result['error_description']).to eq("Threshold must be greater than or equal to 0")
    end
  end

  describe "Update payload" do
    let(:new_payload) { FactoryGirl.create(:payload) }
    
    it "should work" do   
      payload = nfc_tag.payloads.last
      @new_threshold = payload.threshold * 2
         
      put :update, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, :id => payload.id,
          :payload => {:uri => new_payload.uri, :content => new_payload.content, :content_type => 'image', :threshold => @new_threshold}

      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.nfc_tags.count).to eq(1)
      
      tag = subject.current_user.nfc_tags.first
      expect(tag.payloads.count).to eq(3)
      
      expect(payload.reload.uri).to eq(new_payload.uri)
      expect(payload.reload.content).to eq(new_payload.content)
      expect(payload.reload.threshold).to eq(@new_threshold)
      expect(response.status).to eq(200)      
    end

    it "should fail if not found" do      
      payload = nfc_tag.payloads.last
      @new_threshold = payload.threshold * 2

      put :update, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, :id => 0,
          :payload => {:uri => new_payload.uri, :content => new_payload.content, :threshold => @new_threshold}

      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.nfc_tags.count).to eq(1)
      
      tag = subject.current_user.nfc_tags.first
      expect(tag.payloads.count).to eq(3)
      
      expect(response.status).to eq(404)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result['error_description']).to eq(I18n.t('object_not_found', :obj => 'Payload'))
    end

    it "should fail if params invalid" do      
      payload = nfc_tag.payloads.last
      @new_threshold = payload.threshold * 2

      put :update, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, :id => payload.id,
          :payload => {:uri => new_payload.uri, :content => new_payload.content, :threshold => -2}

      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.nfc_tags.count).to eq(1)
      
      tag = subject.current_user.nfc_tags.first
      expect(tag.payloads.count).to eq(3)
      
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result['error_description']).to eq("Validation failed: Threshold must be greater than or equal to 0")
    end

    it "should fail if content type invalid" do      
      payload = nfc_tag.payloads.last
      @new_threshold = payload.threshold * 2

      put :update, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, :id => payload.id,
          :payload => {:uri => new_payload.uri, :content => new_payload.content, :content_type => 'fish', :threshold => 1}

      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.nfc_tags.count).to eq(1)
      
      tag = subject.current_user.nfc_tags.first
      expect(tag.payloads.count).to eq(3)
      
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result['error_description']).to eq("Validation failed: Content type is not included in the list")
    end
  end

  describe "Destroy payload" do
    it "should work" do   
      payload = nfc_tag.payloads.last
      
      delete :destroy, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, :id => payload.id

      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.nfc_tags.count).to eq(1)
      
      tag = subject.current_user.nfc_tags.first
      expect(tag.payloads.count).to eq(2)
      
      expect(response.status).to eq(200)      
    end
    
    it "should fail if not found" do      
      delete :destroy, :version => 1, :tag_id => nfc_tag.tag_id, :auth_token => user.authentication_token, :id => 0

      expect(subject.current_user).to_not be_nil
      expect(subject.current_user.nfc_tags.count).to eq(1)
      
      tag = subject.current_user.nfc_tags.first
      expect(tag.payloads.count).to eq(3)
      
      expect(response.status).to eq(404)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result['error_description']).to eq(I18n.t('object_not_found', :obj => 'Payload'))
    end
  end
end
