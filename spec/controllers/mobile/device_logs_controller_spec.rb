describe Mobile::V1::DeviceLogsController, :type => :controller do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "Log device events" do
    let(:user) { FactoryGirl.create(:user) }
    
    OS = 'Android'
    HARDWARE = 'Samsung Galaxy S5'
    MESSAGE = 'Weird error'
    DETAILS = 'Fish fish Fish'
    
    it "should fail when not authenticated" do
      post :create, :version => 1, :user => user.phone_secret_key, 
                    :os => OS, :hardware => HARDWARE, :message => MESSAGE, :details => DETAILS
      
      expect(subject.current_user).to be_nil
      expect(DeviceLog.count).to eq(0)
      
      expect(response.status).to eq(404)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq(I18n.t('auth_token_not_found'))
      expect(result["user_error"]).to be_nil
    end
    
    it "should fail with no user specified" do
      post :create, :version => 1, :auth_token => user.authentication_token,
                    :os => OS, :hardware => HARDWARE, :message => MESSAGE, :details => DETAILS
      
      expect(subject.current_user).to_not be_nil
      expect(DeviceLog.count).to eq(0)
      
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq("Validation failed: User can't be blank")      
      expect(result["user_error"]).to be_nil
    end
    
    it "should fail with no os specified" do
      post :create, :version => 1, :auth_token => user.authentication_token, :user => user.phone_secret_key,
                    :hardware => HARDWARE, :message => MESSAGE, :details => DETAILS
      
      expect(subject.current_user).to_not be_nil
      expect(DeviceLog.count).to eq(0)
      
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq("Validation failed: Os can't be blank")      
      expect(result["user_error"]).to be_nil
    end
    
    it "should fail with no hardware specified" do
      post :create, :version => 1, :auth_token => user.authentication_token, :user => user.phone_secret_key,
                    :os => OS, :message => MESSAGE, :details => DETAILS
      
      expect(subject.current_user).to_not be_nil
      expect(DeviceLog.count).to eq(0)
      
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq("Validation failed: Hardware can't be blank")      
      expect(result["user_error"]).to be_nil
    end

    it "should fail with no message specified" do
      post :create, :version => 1, :auth_token => user.authentication_token, :user => user.phone_secret_key,
                    :os => OS, :hardware => HARDWARE, :details => DETAILS
      
      expect(subject.current_user).to_not be_nil
      expect(DeviceLog.count).to eq(0)
      
      expect(response.status).to eq(400)
      
      result = JSON.parse(response.body)

      expect(result.keys.include?('response')).to be false
      expect(result.keys.include?('error')).to be true
      expect(result["error_description"]).to eq("Validation failed: Message can't be blank")      
      expect(result["user_error"]).to be_nil
    end

    it "should create one" do
      post :create, :version => 1, :auth_token => user.authentication_token, :user => user.phone_secret_key, 
                    :os => OS, :hardware => HARDWARE, :message => MESSAGE, :details => DETAILS
                    
      expect(subject.current_user).to eq(user)
      expect(response.status).to eq(200)

      event = DeviceLog.first
      
      expect(event.user).to eq(user.phone_secret_key)
      expect(event.os).to eq(OS)
      expect(event.hardware).to eq(HARDWARE)
      expect(event.message).to eq(MESSAGE)
      expect(event.details).to eq(DETAILS)      
    end

    it "should create one with no details" do
      post :create, :version => 1, :auth_token => user.authentication_token, :user => user.phone_secret_key, 
                    :os => OS, :hardware => HARDWARE, :message => MESSAGE
                    
      expect(subject.current_user).to eq(user)
      expect(response.status).to eq(200)

      event = DeviceLog.first
      
      expect(event.user).to eq(user.phone_secret_key)
      expect(event.os).to eq(OS)
      expect(event.hardware).to eq(HARDWARE)
      expect(event.message).to eq(MESSAGE)
      expect(event.details).to be_nil   
    end
  end
end
