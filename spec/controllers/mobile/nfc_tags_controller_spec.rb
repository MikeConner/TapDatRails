describe Mobile::V1::NfcTagsController, :type => :controller do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end
  render_views
 
  describe "Show tag" do
    let(:tag) { FactoryGirl.create(:nfc_tag) }
    
    it "should get the app page" do
      get :show, :version => 1, :id => tag.tag_id
            
      expect(response.status).to eq(200)    
      expect(response.body).to match(tag.tag_id)
    end
  end
 
  describe "Create tag" do
    let(:user) { FactoryGirl.create(:user_with_currencies) }
    let(:random_currency) { FactoryGirl.create(:currency) }
    
    it "should fail with no tag" do
      post :create, :version => 1, :auth_token => user.authentication_token 

      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result['error_description']).to eq(I18n.t('missing_argument', :arg => 'tag'))     
      expect(result['user_error']).to eq(I18n.t('tag_create_error'))     
    end

    it "should fail with no payloads" do
      post :create, :version => 1, :auth_token => user.authentication_token, :tag => {:name => 'Fish', :currency_id => user.currencies.first.id }

      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result['error_description']).to eq(I18n.t('missing_argument', :arg => 'payloads'))     
      expect(result['user_error']).to eq(I18n.t('tag_create_error'))     
    end

    it "should create a minimal bitcoin tag" do
      post :create, :version => 1, :auth_token => user.authentication_token, :tag => {:name => 'New Tag'},
                    :payloads => [{:threshold => 11,
                                   :content_type => 'image', 
                                   :uri => 'http://www.microsoft.com',
                                   :description => 'test'}] 

      expect(subject.current_user).to eq(user)
      expect(user.nfc_tags.count).to eq(1)
      expect(NfcTag.count).to eq(1)
      expect(NfcTag.first.payloads.count).to eq(1)
      expect(NfcTag.first.currency).to be_nil
            
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(result['response'].keys.include?('id')).to be true
      expect(result['response']['id']).to_not be_blank
      expect(result['response']['system_id']).to_not be_blank
      expect(result['response']['name']).to eq('New Tag')
      expect(result.keys.include?('error')).to be false      
    end

    it "should create bitcoin tag" do
      post :create, :version => 1, :auth_token => user.authentication_token, :tag => {:name => 'Fish'},
                    :payloads => [{:threshold => 1,
                                   :content_type => 'image', 
                                   :content => 'pole dance', 
                                   :description => 'description',
                                   :mobile_payload_image_url => 'http://machovy.com/stripper.jpg',
                                   :mobile_payload_thumb_url => 'http://machovy.com/stripper_thumb.jpg'}, 
                                  {:threshold => 5,
                                   :content_type => 'video',
                                   :content => 'twerking contest',
                                   :description => 'description',
                                   :uri => 'http://machovy.com/insider/furrytwerk.mpg',
                                   :mobile_payload_image_url => 'http://machovy.com/miley.jpg',
                                   :mobile_payload_thumb_url => 'http://machovy.com/miley_thumb.jpg', 
                                  }]

      expect(subject.current_user).to eq(user)
      expect(user.nfc_tags.count).to eq(1)
      expect(NfcTag.count).to eq(1)
      expect(NfcTag.first.payloads.count).to eq(2)
      expect(NfcTag.first.currency).to be_nil
            
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(result['response'].keys.include?('id')).to be true
      expect(result['response']['id']).to_not be_blank
      expect(result['response']['system_id']).to_not be_blank
      expect(result['response']['name']).to eq('Fish')
      expect(result.keys.include?('error')).to be false      
    end

    it "should fail with invalid currency" do
      post :create, :version => 1, :auth_token => user.authentication_token, :tag => {:name => 'Fish', :currency_id => 0 },
                    :payloads => [{:threshold => 1,
                                   :content_type => 'image', 
                                   :content => 'pole dance', 
                                   :description => 'description',
                                   :mobile_payload_image_url => 'http://machovy.com/stripper.jpg',
                                   :mobile_payload_thumb_url => 'http://machovy.com/stripper_thumb.jpg'}, 
                                  {:threshold => 5,
                                   :content_type => 'video',
                                   :content => 'twerking contest',
                                   :description => 'description',
                                   :uri => 'http://machovy.com/insider/furrytwerk.mpg',
                                   :mobile_payload_image_url => 'http://machovy.com/miley.jpg',
                                   :mobile_payload_thumb_url => 'http://machovy.com/miley_thumb.jpg', 
                                  }]

      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result['error_description']).to eq(I18n.t('invalid_currency'))     
      expect(result['user_error']).to eq(I18n.t('tag_create_error'))     
    end

    it "should fail with unowned currency" do
      post :create, :version => 1, :auth_token => user.authentication_token, :tag => {:name => 'Fish', :currency_id => random_currency.id },
                    :payloads => [{:threshold => 1,
                                   :content_type => 'image', 
                                   :content => 'pole dance', 
                                   :description => 'description',
                                   :mobile_payload_image_url => 'http://machovy.com/stripper.jpg',
                                   :mobile_payload_thumb_url => 'http://machovy.com/stripper_thumb.jpg'}, 
                                  {:content_type => 'video',
                                   :content => 'twerking contest',
                                   :description => 'description',
                                   :uri => 'http://machovy.com/insider/furrytwerk.mpg',
                                   :mobile_payload_image_url => 'http://machovy.com/miley.jpg',
                                   :mobile_payload_thumb_url => 'http://machovy.com/miley_thumb.jpg', 
                                  }]

      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result['error_description']).to eq(I18n.t('not_currency_owner'))     
      expect(result['user_error']).to eq(I18n.t('tag_create_error'))     
    end

    it "should fail with no name" do
      post :create, :version => 1, :auth_token => user.authentication_token, :tag => {:currency_id => user.currencies.first.id },
                    :payloads => [{:threshold => 1,
                                   :content_type => 'image', 
                                   :content => 'pole dance', 
                                   :description => 'description',
                                   :mobile_payload_image_url => 'http://machovy.com/stripper.jpg',
                                   :mobile_payload_thumb_url => 'http://machovy.com/stripper_thumb.jpg'}, 
                                  {:content_type => 'video',
                                   :content => 'twerking contest',
                                   :description => 'description',
                                   :uri => 'http://machovy.com/insider/furrytwerk.mpg',
                                   :mobile_payload_image_url => 'http://machovy.com/miley.jpg',
                                   :mobile_payload_thumb_url => 'http://machovy.com/miley_thumb.jpg', 
                                  }]

      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result['error_description']).to eq(I18n.t('missing_argument', :arg => 'tag:name'))     
      expect(result['user_error']).to eq(I18n.t('tag_create_error'))     
    end

    it "should fail with invalid payload" do
      post :create, :version => 1, :auth_token => user.authentication_token, 
                    :tag => {:name => 'Fish', :currency_id => user.currencies.first.id },
                    :payloads => [{:threshold => 1,
                                   :content_type => 'image', 
                                   :content => 'pole dance', 
                                   :description => 'description',
                                   :mobile_payload_image_url => 'http://machovy.com/stripper.jpg',
                                   :mobile_payload_thumb_url => 'http://machovy.com/stripper_thumb.jpg'}, 
                                  {:content_type => 'video',
                                   :content => 'twerking contest',
                                   :description => 'description',
                                   :uri => 'http://machovy.com/insider/furrytwerk.mpg',
                                   :mobile_payload_image_url => 'http://machovy.com/miley.jpg',
                                   :mobile_payload_thumb_url => 'http://machovy.com/miley_thumb.jpg', 
                                  }]

      expect(response.status).to eq(422)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result['error_description']).to eq('The current resource was deemed invalid.')     
      expect(result['messages']).to_not be_blank
    end
    
    it "creates a tag successfully" do
      post :create, :version => 1, :auth_token => user.authentication_token, 
                    :tag => {:name => 'Fish', :currency_id => user.currencies.first.id },
                    :payloads => [{:threshold => 1,
                                   :content_type => 'image', 
                                   :content => 'pole dance', 
                                   :description => 'description',
                                   :mobile_payload_image_url => 'http://machovy.com/stripper.jpg',
                                   :mobile_payload_thumb_url => 'http://machovy.com/stripper_thumb.jpg'}, 
                                  {:threshold => 5,
                                   :content_type => 'video',
                                   :content => 'twerking contest',
                                   :description => 'description',
                                   :uri => 'http://machovy.com/insider/furrytwerk.mpg',
                                   :mobile_payload_image_url => 'http://machovy.com/miley.jpg',
                                   :mobile_payload_thumb_url => 'http://machovy.com/miley_thumb.jpg', 
                                  }]
      
      expect(subject.current_user).to eq(user)
      expect(user.nfc_tags.count).to eq(1)
      expect(NfcTag.count).to eq(1)
      expect(NfcTag.first.payloads.count).to eq(2)
            
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)
      
      expect(result['response'].keys.include?('id')).to be true
      expect(result['response']['id']).to_not be_blank
      expect(result['response']['system_id']).to_not be_blank
      expect(result['response']['name']).to eq('Fish')
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
        put :update, :version => 1, :id => 0, :auth_token => user.authentication_token, :tag => { :name => @new_name }, :tag_id => user.nfc_tags.first.tag_id
  
        sleep 2
        
        expect(subject.current_user).to_not be_nil
        expect(user.nfc_tags.count).to eq(5)
        expect(NfcTag.count).to eq(5)
        expect(user.nfc_tags.first.reload.name).to eq(@new_name)
        expect(response.status).to eq(200)
      end    
     
      describe "it should alter payloads" do
        let(:tag) { FactoryGirl.create(:nfc_tag_with_payloads) }
        
        it "should be initialized" do
          expect(tag.payloads.count).to eq(3)
        end
        
        it "should overwrite them" do
          put :update, :version => 1, :id => 0, :auth_token => tag.user.authentication_token, :tag_id => tag.tag_id, :tag => { :name => 'Fish' },
                      :payloads => [{:threshold => 5,
                                     :content_type => 'image', 
                                     :content => 'pole dance', 
                                     :description => 'description',
                                     :mobile_payload_image_url => 'http://machovy.com/stripper.jpg',
                                     :mobile_payload_thumb_url => 'http://machovy.com/stripper_thumb.jpg'}, 
                                    {:threshold => 50,
                                     :content_type => 'image',
                                     :content => 'twerking contest',
                                     :description => 'description',
                                     :mobile_payload_image_url => 'http://machovy.com/miley.jpg',
                                     :mobile_payload_thumb_url => 'http://machovy.com/miley_thumb.jpg', 
                                    }]
                                    
          expect(subject.current_user.nfc_tags.first.reload.payloads.count).to eq(2)
          expect(subject.current_user.nfc_tags.first.reload.payloads.last.threshold).to eq(50)
        end
      end
      
      it "should update payloads" do
        put :update, :version => 1, :id => 0, :auth_token => user.authentication_token, :tag => { :name => @new_name }, :tag_id => user.nfc_tags.first.tag_id,
                    :payloads => [{:threshold => 5,
                                   :content_type => 'image', 
                                   :content => 'pole dance', 
                                   :description => 'description',
                                   :mobile_payload_image_url => 'http://machovy.com/stripper.jpg',
                                   :mobile_payload_thumb_url => 'http://machovy.com/stripper_thumb.jpg'}, 
                                  {:threshold => 50,
                                   :content_type => 'image',
                                   :content => 'twerking contest',
                                   :description => 'description',
                                   :mobile_payload_image_url => 'http://machovy.com/miley.jpg',
                                   :mobile_payload_thumb_url => 'http://machovy.com/miley_thumb.jpg', 
                                  }]
  
        sleep 2
        
        expect(subject.current_user).to_not be_nil
        expect(user.nfc_tags.count).to eq(5)
        expect(NfcTag.count).to eq(5)
        expect(user.nfc_tags.first.reload.name).to eq(@new_name)
        expect(subject.current_user.nfc_tags.first.payloads.last.threshold).to eq(50)      
        expect(response.status).to eq(200)
      end    
      
      it "should update by legible tag_id" do
        put :update, :version => 1, :id => 0, :auth_token => user.authentication_token, :tag => { :name => @new_name }, :tag_id => user.nfc_tags.first.legible_id
  
        sleep 2
        
        expect(subject.current_user).to_not be_nil
        expect(user.nfc_tags.count).to eq(5)
        expect(NfcTag.count).to eq(5)
        expect(user.nfc_tags.first.reload.name).to eq(@new_name)
              
        expect(response.status).to eq(200)
      end    

      it "should update by system id" do
        put :update, :version => 1, :id => user.nfc_tags.first.id, :auth_token => user.authentication_token, :tag => { :name => @new_name }
  
        sleep 2
        
        expect(subject.current_user).to_not be_nil
        expect(user.nfc_tags.count).to eq(5)
        expect(NfcTag.count).to eq(5)
        expect(user.nfc_tags.first.reload.name).to eq(@new_name)
              
        expect(response.status).to eq(200)
      end    

      it "should fail if no id" do
        put :update, :version => 1, :id => 0, :auth_token => user.authentication_token, :tag => { :name => @new_name }
  
        expect(subject.current_user).to_not be_nil
        expect(user.nfc_tags.count).to eq(5)
        expect(NfcTag.count).to eq(5)
        expect(user.nfc_tags.first.reload.name).to_not eq(@new_name)
              
        expect(response.status).to eq(404)
        
        result = JSON.parse(response.body)
  
        expect(result.keys.include?('response')).to be false
        expect(result.keys.include?('error')).to be true
        expect(result['error_description']).to eq("The requested resource could not be found.")     
        expect(result['error']).to eq('not_found')     
      end   
       
      it "should succeed if no name" do
        put :update, :version => 1, :id => user.nfc_tags.first.id, :auth_token => user.authentication_token
  
        expect(subject.current_user).to_not be_nil
        expect(user.nfc_tags.count).to eq(5)
        expect(NfcTag.count).to eq(5)
        expect(user.nfc_tags.first.reload.name).to_not eq(@new_name)
              
        expect(response.status).to eq(200)
      end    

      it "should fail if not found" do
        put :update, :version => 1, :id => user.nfc_tags.first.id + 100, :auth_token => user.authentication_token, :tag => { :name => @new_name }
  
        expect(subject.current_user).to_not be_nil
        expect(user.nfc_tags.count).to eq(5)
        expect(NfcTag.count).to eq(5)
        expect(user.nfc_tags.first.reload.name).to_not eq(@new_name)
              
        expect(response.status).to eq(404)
        
        result = JSON.parse(response.body)
        
        puts result.inspect
        expect(result.keys.include?('response')).to be false
        expect(result.keys.include?('error')).to be true
        expect(result['error_description']).to eq("The requested resource could not be found.")
        expect(result['error']).to eq('not_found')     
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
        expect(r['payloads']).to be_empty
      end
      
      expect(result['count']).to eq(5)
      expect(result.keys.include?('error')).to be false      
    end
  end

  describe "List tags with payloads" do
    let(:tag) { FactoryGirl.create(:nfc_tag_with_payloads) }
    
    it "list successfully" do      
      get :index, :version => 1, :auth_token => tag.user.authentication_token

      expect(subject.current_user).to_not be_nil
      expect(NfcTag.count).to eq(1)
            
      expect(response.status).to eq(200)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be true 
      result['response'].each do |r|
        expect(r['id']).to_not be_blank
        expect(r['system_id']).to_not be_blank
        expect(r['name']).to_not be_blank
        expect(r['payloads'].count).to eq(3)
      end
      
      expect(result['count']).to eq(1)
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
      expect(result['user_error']).to eq(I18n.t('invalid_tag'))     
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
      expect(result['user_error']).to eq(I18n.t('invalid_tag'))     
    end
  end        
end
