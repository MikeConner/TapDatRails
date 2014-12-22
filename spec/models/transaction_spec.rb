# == Schema Information
#
# Table name: transactions
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  nfc_tag_id     :integer
#  payload_id     :integer
#  dest_id        :integer
#  satoshi_amount :integer
#  dollar_amount  :integer
#  comment        :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  slug           :string(255)
#

describe Transaction do
  let(:user) { FactoryGirl.create(:user) }
  let(:other) { FactoryGirl.create(:user) }
  let(:tag) { FactoryGirl.create(:nfc_tag, :user => other) }
  let(:payload) { FactoryGirl.create(:payload, :nfc_tag => tag) }
  let(:transaction) { FactoryGirl.create(:transaction, :user => user, :dest_id => other.id, :nfc_tag => tag, :payload => payload) }
  
  subject { transaction }
  
  it "should respond to everything" do
    expect(transaction).to respond_to(:satoshi_amount)
    expect(transaction).to respond_to(:dollar_amount)  
    expect(transaction).to respond_to(:comment)  
    expect(transaction).to respond_to(:slug)  
  end
  
  its(:user) { should be == user }
  its(:nfc_tag) { should be == tag }
  its(:payload) { should be == payload }
  it { should be_valid }

  it "should have a slug" do
    expect(transaction.slug).not_to be_nil
  end  
    
  describe "missing user" do
    before { transaction.user_id = nil }
    
    it { should_not be_valid }
  end
  
  describe "missing dest" do
    before { transaction.dest_id = nil }
    
    it { should_not be_valid }
  end
  
  describe "Invalid satoshi amount" do
    [-1, 0.25, 'abc'].each do |amount|
      before { transaction.satoshi_amount = amount }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid dollar amount" do
    [-1, 0.25, 'abc'].each do |amount|
      before { transaction.dollar_amount = amount }
      
      it { should_not be_valid }
    end
  end
  
  describe "Default amount" do
    before do
      expect(transaction.dollar_amount).to eq(1)
      expect(transaction.satoshi_amount).to eq(10000)
    end
    
    it { should be_valid }
  end
  
  describe "Details" do
    let(:transaction) { FactoryGirl.create(:transaction_with_details) }
    
    it "should have details" do
      expect(transaction.transaction_details.count).to eq(2)
    end
    
    describe "destroy" do
      before { transaction.destroy }
      
      it "should be gone" do
        expect(TransactionDetail.count).to eq(0)
      end
    end
  end
end
