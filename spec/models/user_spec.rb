# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  email                    :string(255)      default(""), not null
#  encrypted_password       :string(255)      default(""), not null
#  name                     :string(255)      default(""), not null
#  reset_password_token     :string(255)
#  reset_password_sent_at   :datetime
#  remember_created_at      :datetime
#  sign_in_count            :integer          default(0)
#  current_sign_in_at       :datetime
#  last_sign_in_at          :datetime
#  current_sign_in_ip       :string(255)
#  last_sign_in_ip          :string(255)
#  authentication_token     :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  phone_secret_key         :string(16)       not null
#  inbound_btc_address      :string(255)
#  outbound_btc_address     :string(255)
#  satoshi_balance          :integer          default(0), not null
#  profile_image            :string(255)
#  profile_thumb            :string(255)
#  mobile_profile_image_url :string(255)
#  mobile_profile_thumb_url :string(255)
#  inbound_btc_qrcode       :string(255)
#

describe User do  
  let(:user) { FactoryGirl.create(:user) }
  
  subject { user }
  
  it "should respond to everything (instant)" do
    expect(user).to respond_to(:name)
    expect(user).to respond_to(:email)
    expect(user).to respond_to(:phone_secret_key)
    expect(user).to respond_to(:inbound_btc_address)
    expect(user).to respond_to(:outbound_btc_address)
    expect(user).to respond_to(:satoshi_balance)
    expect(user).to respond_to(:authentication_token)
    expect(user).to respond_to(:profile_image)
    expect(user).to respond_to(:profile_thumb)
    expect(user).to respond_to(:mobile_profile_image_url)
    expect(user).to respond_to(:mobile_profile_thumb_url)
    expect(user).to respond_to(:inbound_btc_qrcode)
  end
  
  it { should be_valid }
  
  describe "currencies" do
    let(:user) { FactoryGirl.create(:user_with_currencies) }
    
    it "should have currencies" do
      expect(user.currencies.count).to eq(2)
    end
    
    describe "delete" do
      before { user.destroy }
      
      it "should be gone" do
        expect(Currency.count).to eq(0)
      end
    end
  end

  describe "balances" do
    let(:user) { FactoryGirl.create(:user_with_balances) }
    
    it "should have balances" do
      expect(user.balances.count).to eq(3)
    end
    
    describe "delete" do
      before { user.destroy }
      
      it "should be gone" do
        expect(Balance.count).to eq(0)
      end
    end
  end
  
  describe "Missing name" do
    before { user.name = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Missing phone secret key" do
    before { user.phone_secret_key = ' ' }
    
    it { should_not be_valid }
  end

  describe "Key too long" do
    before { user.phone_secret_key = 'x'*(User::SECRET_KEY_LEN + 1) }
    
    it { should_not be_valid }
  end
  
  describe "Missing satoshi_balance" do
    [-1, 0.5, 'abc'].each do |balance|
      before { user.satoshi_balance = balance }
    
      it { should_not be_valid }
    end
  end
  
  describe "Missing email" do
    before { user.email = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Valid emails" do
    ApplicationHelper::VALID_EMAILS.each do |email|
      before { user.email = email }
      
      it { should be_valid }
    end
  end

  describe "Invalid emails" do
    ApplicationHelper::INVALID_EMAILS.each do |email|
      before { user.email = email }
      
      it { should_not be_valid }
    end
  end
  
  describe "nfc tags" do
    let(:user) { FactoryGirl.create(:user_with_tags) }
    
    it "should have tags" do
      expect(user.nfc_tags.count).to eq(5)
    end
    
    describe "delete" do
      before { user.destroy }
      
      it "should be gone" do
        expect(NfcTag.count).to eq(0)
      end
    end
  end

  describe "transactions" do
    let(:user) { FactoryGirl.create(:user_with_transactions) }
    
    it "should have transactions" do
      expect(user.transactions.count).to eq(2)
    end
    
    describe "delete" do    
      before { user.destroy }
        
      it "should not be gone" do
        expect(user.errors.count).to_not eq(0)
        
        expect(Transaction.count).to eq(2)
      end
    end
    
    describe "Delete dependents first" do
      before do
        user.transactions.destroy_all
        user.destroy
      end
      
      it "should now be gone" do
        expect(Transaction.count).to eq(0)
      end
    end
  end

  describe "transactions with details" do
    let(:user) { FactoryGirl.create(:user_with_details) }
    
    it "should have transactions" do
      expect(user.transactions.count).to eq(2)
      expect(user.transaction_details.count).to eq(4)
    end
    
    describe "delete" do 
      before { user.destroy }
           
      it "should not be gone" do
        expect(user.errors.count).to_not eq(0)
        
        expect(Transaction.count).to eq(2)
        expect(TransactionDetail.count).to eq(4)
      end
    end
    
    describe "Delete dependents first" do
      before do
        user.transactions.destroy_all
        user.destroy
      end
      
      it "should now be gone" do
        expect(Transaction.count).to eq(0)
        expect(TransactionDetail.count).to eq(0)
      end
    end
  end
end
