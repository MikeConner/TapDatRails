# == Schema Information
#
# Table name: device_logs
#
#  id         :integer          not null, primary key
#  user       :string(16)       not null
#  os         :string(32)       not null
#  hardware   :string(48)       not null
#  message    :string(255)      not null
#  details    :text
#  created_at :datetime
#  updated_at :datetime
#

describe DeviceLog do
  let(:log) { FactoryGirl.create(:device_log) }
  
  it "should respond to everything" do
    expect(log).to respond_to(:user)
    expect(log).to respond_to(:os)
    expect(log).to respond_to(:hardware)
    expect(log).to respond_to(:message)
    expect(log).to respond_to(:details)
  end
 
  it "should be valid" do
    expect(log).to be_valid
  end
  
  describe "Missing user" do
    before { log.user = ' ' }
    
    it "should fail" do
      expect(log).to_not be_valid
    end
  end

  describe "Invalid user" do
    before { log.user = 'x'*(User::SECRET_KEY_LEN + 1) }
    
    it "should fail" do
      expect(log).to_not be_valid
    end
  end

  describe "Missing os" do
    before { log.os = ' ' }
    
    it "should fail" do
      expect(log).to_not be_valid
    end
  end

  describe "Invalid os" do
    before { log.os = 'x'*(DeviceLog::OS_DESC_LIMIT + 1) }
    
    it "should fail" do
      expect(log).to_not be_valid
    end
  end

  describe "Missing hardware" do
    before { log.hardware = ' ' }
    
    it "should fail" do
      expect(log).to_not be_valid
    end
  end

  describe "Invalid hardware" do
    before { log.hardware = 'x'*(DeviceLog::HARDWARE_DESC_LIMIT + 1) }
    
    it "should fail" do
      expect(log).to_not be_valid
    end
  end
end
