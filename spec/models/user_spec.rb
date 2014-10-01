# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  name                   :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  authentication_token   :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  phone_secret_key       :string(16)       not null
#  inbound_btc_address    :string(255)
#  outbound_btc_address   :string(255)
#  satoshi_balance        :integer          default(0), not null
#  profile_image          :string(255)
#  profile_thumb          :string(255)
#

describe User do  
  let(:user) { FactoryGirl.create(:user) }
  
  subject { user }
  
  it "should respond to everything (instant)" do
    user.should respond_to(:name)
    user.should respond_to(:email)
    user.should respond_to(:phone_secret_key)
    user.should respond_to(:inbound_btc_address)
    user.should respond_to(:outbound_btc_address)
    user.should respond_to(:satoshi_balance)
    user.should respond_to(:authentication_token)
    user.should respond_to(:profile_image)
    user.should respond_to(:profile_thumb)
  end
  
  it { should be_valid }
  
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
      user.nfc_tags.count.should be == 5
    end
    
    describe "delete" do
      before { user.destroy }
      
      it "should be gone" do
        NfcTag.count.should be == 0
      end
    end
  end

  describe "transactions" do
    let(:user) { FactoryGirl.create(:user_with_transactions) }
    
    it "should have transactions" do
      user.transactions.count.should be == 2
    end
    
    describe "delete" do      
      it "should not be gone" do
        expect { user.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
        
        Transaction.count.should be == 2
      end
    end
    
    describe "Delete dependents first" do
      before do
        user.transactions.destroy_all
        user.destroy
      end
      
      it "should now be gone" do
        Transaction.count.should be == 0
      end
    end
  end

  describe "transactions with details" do
    let(:user) { FactoryGirl.create(:user_with_details) }
    
    it "should have transactions" do
      user.transactions.count.should be == 2
      user.transaction_details.count.should be == 4
    end
    
    describe "delete" do      
      it "should not be gone" do
        expect { user.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
        
        Transaction.count.should be == 2
        TransactionDetail.count.should be == 4
      end
    end
    
    describe "Delete dependents first" do
      before do
        user.transactions.destroy_all
        user.destroy
      end
      
      it "should now be gone" do
        Transaction.count.should be == 0
        TransactionDetail.count.should be == 0
      end
    end
  end
end
