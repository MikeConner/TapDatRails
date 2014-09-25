describe Mobile::V1::NfcTagsController, :type => :controller do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe "Create tag" do
    let(:user) { FactoryGirl.create(:user) }
    
    it "creates a tag successfully" do
      post :create, :version => 1, :auth_token => user.authentication_token
      
      subject.current_user.should_not be_nil
      user.nfc_tags.count.should be == 1
      NfcTag.count.should be == 1
            
      response.status.should be == 200
      
      result = JSON.parse(response.body)
      result['response'].keys.include?('id').should be_true
      result['response']['id'].should_not be_blank
      result['response']['name'].should_not be_blank
      result['response']['name'].should be == 'Tag name'
      result.keys.include?('error').should be_false      
    end
  end
  
  describe "Update tag" do
    let(:user) { FactoryGirl.create(:user_with_tags) }
    
    describe "updates a tag successfully" do
      before do
        @old_name = user.nfc_tags.first.name
        @new_name = 'Candy'
      end
      
      it "should work" do
        put :update, :version => 1, :id => 0, :auth_token => user.authentication_token, :name => @new_name, :tag_id => user.nfc_tags.first.tag_id
  
        sleep 2
        
        subject.current_user.should_not be_nil
        user.nfc_tags.count.should be == 5
        NfcTag.count.should be == 5
        user.nfc_tags.first.reload.name.should be == @new_name
              
        response.status.should be == 200
      end    
    end
  end

  describe "List tags" do
    let(:user) { FactoryGirl.create(:user_with_tags) }
    
    it "list successfully" do      
      get :index, :version => 1, :auth_token => user.authentication_token

      subject.current_user.should_not be_nil
      user.nfc_tags.count.should be == 5
      NfcTag.count.should be == 5
            
      response.status.should be == 200
      
      result = JSON.parse(response.body)
      puts result
      result.keys.include?('response').should be_true 
      result['count'].should be == 5
      result.keys.include?('error').should be_false      
    end
  end
end
