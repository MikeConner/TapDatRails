describe Mobile::V1::NfcTagsController, :type => :controller do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe "Create tag" do
    let(:user) { FactoryGirl.create(:user) }
    
    it "creates a tag successfully" do
      post :create, :version => 1, :auth_token => user.authentication_token
      
      expect(subject.current_user).to_not be_nil
      expect(user.nfc_tags.count).to eq(1)
      expect(NfcTag.count).to eq(1)
            
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(result['response'].keys.include?('id')).to be true
      expect(result['response']['id']).to_not be_blank
      expect(result['response']['system_id']).to_not be_blank
      expect(result['response']['name']).to_not be_blank
      expect(result['response']['name']).to eq('Tag name')
      expect(result.keys.include?('error')).to be false      
    end
  end
  
  describe "Update tag" do
    let(:user) { FactoryGirl.create(:user_with_tags) }
    
    describe "updates a tag successfully" do
      before do
        @old_name = user.nfc_tags.first.name
        @new_name = 'Candy'
      end
      
      it "should update by tag_id" do
        put :update, :version => 1, :id => 0, :auth_token => user.authentication_token, :name => @new_name, :tag_id => user.nfc_tags.first.tag_id
  
        sleep 2
        
        expect(subject.current_user).to_not be_nil
        expect(user.nfc_tags.count).to eq(5)
        expect(NfcTag.count).to eq(5)
        expect(user.nfc_tags.first.reload.name).to eq(@new_name)
              
        expect(response.status).to eq(200)
      end    

      it "should update by legible tag_id" do
        put :update, :version => 1, :id => 0, :auth_token => user.authentication_token, :name => @new_name, :tag_id => user.nfc_tags.first.legible_id
  
        sleep 2
        
        expect(subject.current_user).to_not be_nil
        expect(user.nfc_tags.count).to eq(5)
        expect(NfcTag.count).to eq(5)
        expect(user.nfc_tags.first.reload.name).to eq(@new_name)
              
        expect(response.status).to eq(200)
      end    

      it "should update by system id" do
        put :update, :version => 1, :id => user.nfc_tags.first.id, :auth_token => user.authentication_token, :name => @new_name
  
        sleep 2
        
        expect(subject.current_user).to_not be_nil
        expect(user.nfc_tags.count).to eq(5)
        expect(NfcTag.count).to eq(5)
        expect(user.nfc_tags.first.reload.name).to eq(@new_name)
              
        expect(response.status).to eq(200)
      end    

      it "should fail if no id" do
        put :update, :version => 1, :id => 0, :auth_token => user.authentication_token, :name => @new_name
  
        expect(subject.current_user).to_not be_nil
        expect(user.nfc_tags.count).to eq(5)
        expect(NfcTag.count).to eq(5)
        expect(user.nfc_tags.first.reload.name).to_not eq(@new_name)
              
        expect(response.status).to eq(400)
        
        result = JSON.parse(response.body)
  
        expect(result.keys.include?('response')).to be false
        expect(result.keys.include?('error')).to be true
        expect(result['error_description']).to eq(I18n.t('missing_argument', :arg => 'tag_id'))     
      end   
       
      it "should fail if no name" do
        put :update, :version => 1, :id => user.nfc_tags.first.id, :auth_token => user.authentication_token
  
        expect(subject.current_user).to_not be_nil
        expect(user.nfc_tags.count).to eq(5)
        expect(NfcTag.count).to eq(5)
        expect(user.nfc_tags.first.reload.name).to_not eq(@new_name)
              
        expect(response.status).to eq(400)
        
        result = JSON.parse(response.body)
  
        expect(result.keys.include?('response')).to be false
        expect(result.keys.include?('error')).to be true
        expect(result['error_description']).to eq(I18n.t('missing_argument', :arg => 'name'))       
      end    

      it "should fail if not found" do
        put :update, :version => 1, :id => user.nfc_tags.first.id + 100, :auth_token => user.authentication_token, :name => @new_name
  
        expect(subject.current_user).to_not be_nil
        expect(user.nfc_tags.count).to eq(5)
        expect(NfcTag.count).to eq(5)
        expect(user.nfc_tags.first.reload.name).to_not eq(@new_name)
              
        expect(response.status).to eq(404)
        
        result = JSON.parse(response.body)
  
        expect(result.keys.include?('response')).to be false
        expect(result.keys.include?('error')).to be true
        expect(result['error_description']).to eq(I18n.t('object_not_found', :obj => 'NFC Tag'))
      end   
    end
  end

  describe "List tags" do
    let(:user) { FactoryGirl.create(:user_with_tags) }
    
    it "list successfully" do      
      get :index, :version => 1, :auth_token => user.authentication_token

      expect(subject.current_user).to_not be_nil
      expect(user.nfc_tags.count).to eq(5)
      expect(NfcTag.count).to eq(5)
            
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be true 
      result['response'].each do |r|
        expect(r['id']).to_not be_blank
        expect(r['system_id']).to_not be_blank
        expect(r['name']).to_not be_blank
      end
      
      expect(result['count']).to eq(5)
      expect(result.keys.include?('error')).to be false      
    end
  end
  
  describe "Destroy tag" do
    let(:user) { FactoryGirl.create(:user_with_tags) }
    
    it "should destroy one (by system id)" do      
      expect(user.nfc_tags.count).to eq(5)

      delete :destroy, :version => 1, :id => user.nfc_tags.first.id, :auth_token => user.authentication_token

      expect(subject.current_user).to_not be_nil
      expect(user.nfc_tags.count).to eq(4)
      expect(NfcTag.count).to eq(4)
            
      expect(response.status).to eq(200)      
    end    

    it "should destroy one (by tag id)" do      
      expect(user.nfc_tags.count).to eq(5)

      delete :destroy, :version => 1, :id => 0, :auth_token => user.authentication_token, :tag_id => user.nfc_tags.first.tag_id

      expect(subject.current_user).to_not be_nil
      expect(user.nfc_tags.count).to eq(4)
      expect(NfcTag.count).to eq(4)
            
      expect(response.status).to eq(200)      
    end    

    it "should destroy one (by legible tag id)" do      
      expect(user.nfc_tags.count).to eq(5)

      expect(user.nfc_tags.first.legible_id.include?('-')).to be true
      
      delete :destroy, :version => 1, :id => 0, :auth_token => user.authentication_token, :tag_id => user.nfc_tags.first.legible_id

      expect(subject.current_user).to_not be_nil
      expect(user.nfc_tags.count).to eq(4)
      expect(NfcTag.count).to eq(4)
            
      expect(response.status).to eq(200)      
    end    

    it "should fail to destroy if no tag" do      
      expect(user.nfc_tags.count).to eq(5)

      delete :destroy, :version => 1, :id => 0, :auth_token => user.authentication_token

      expect(subject.current_user).to_not be_nil
      expect(user.nfc_tags.count).to eq(5)
      expect(NfcTag.count).to eq(5)
            
      expect(response.status).to eq(400)      
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result['error_description']).to eq(I18n.t('missing_argument', :arg => 'tag_id'))
    end    

    it "should fail to destroy if id not found" do      
      expect(user.nfc_tags.count).to eq(5)

      delete :destroy, :version => 1, :id => user.nfc_tags.first.id + 100, :auth_token => user.authentication_token

      expect(subject.current_user).to_not be_nil
      expect(user.nfc_tags.count).to eq(5)
      expect(NfcTag.count).to eq(5)
            
      expect(response.status).to eq(404)     
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result['error_description']).to eq(I18n.t('object_not_found', :obj => 'NFC Tag'))
    end    
  end
end
