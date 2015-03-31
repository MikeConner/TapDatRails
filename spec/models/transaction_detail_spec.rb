# == Schema Information
#
# Table name: transaction_details
#
#  id              :integer          not null, primary key
#  transaction_id  :integer
#  subject_id      :integer          not null
#  target_id       :integer          not null
#  credit          :integer
#  debit           :integer
#  conversion_rate :decimal(, )      not null
#  created_at      :datetime
#  updated_at      :datetime
#  currency        :string(16)       default("USD"), not null
#

describe TransactionDetail do
  let(:user) { FactoryGirl.create(:user) }
  let(:other) { FactoryGirl.create(:user) }
  let(:tag) { FactoryGirl.create(:nfc_tag, :user => other) }
  let(:payload) { FactoryGirl.create(:payload, :nfc_tag => tag) }
  let(:transaction) { FactoryGirl.create(:transaction, :user => user, :dest_id => other.id, :nfc_tag => tag, :payload => payload) }
  let(:detail) { FactoryGirl.create(:transaction_detail, :transaction_id => transaction, :subject_id => user.id, :target_id => other.id) }
  
  subject { detail }
  
  it "should respond to everything" do
    expect(detail).to respond_to(:credit)
    expect(detail).to respond_to(:debit)  
    expect(detail).to respond_to(:conversion_rate)  
    expect(detail).to respond_to(:currency)  
  end
  
  it { should be_valid }
    
  describe "missing subject" do
    before { detail.subject_id = nil }
    
    it { should_not be_valid }
  end
  
  describe "missing target" do
    before { detail.target_id = nil }
    
    it { should_not be_valid }
  end
  
  describe "missing currency" do
    before { detail.currency = nil }
    
    it { should_not be_valid }
  end
  
  describe "currency too long" do
    before { detail.currency = '$'*(TransactionDetail::MAX_CURRENCY_LEN + 1) }
    
    it { should_not be_valid }
  end
  
  describe "Invalid conversion rate" do
    [-1, 0, 'abc', nil].each do |rate|
      before { detail.conversion_rate = rate }
      
      it { should_not be_valid }
    end
  end

  describe "No amount at all" do
    before do
      detail.credit = nil
      detail.debit = nil
    end
    
    it { should_not be_valid }
  end
end
