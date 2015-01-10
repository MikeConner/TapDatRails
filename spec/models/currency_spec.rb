# == Schema Information
#
# Table name: currencies
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  name              :string(24)       not null
#  icon              :string(255)
#  denominations     :string(255)
#  expiration_days   :integer
#  status            :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  reserve_balance   :integer          default(0), not null
#  icon_processing   :boolean
#  amount_per_dollar :integer          default(100), not null
#

describe Currency do
  let(:user) { FactoryGirl.create(:user) }
  let(:currency) { FactoryGirl.create(:currency, :user => user) }
  
  subject { currency }
  
  it "should respond to everything" do
    expect(currency).to respond_to(:name)
    expect(currency).to respond_to(:icon)
    expect(currency).to respond_to(:icon_processing)
    expect(currency).to respond_to(:remote_icon_url)
    expect(currency).to respond_to(:denominations)
    expect(currency).to respond_to(:expiration_days)
    expect(currency).to respond_to(:status)
    expect(currency).to respond_to(:reserve_balance)
    expect(currency).to respond_to(:amount_per_dollar)
  end
  
  its(:user) { should be == user }
  
  it { should be_valid }
  
  describe "Missing reserve balance" do
    before { currency.reserve_balance = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Invalid reserve balance" do
    [-2, 0.5, 'abc'].each do |balance|
      before { currency.reserve_balance = balance }
      
      it { should_not be_valid }
    end
  end
  
  describe "invalid expiration days" do
    [-1, 0.25, 'abc'].each do |exp|
      before { currency.expiration_days = exp }
      
      it { should_not be_valid }
    end
  end
  
  describe "missing name" do
    before { currency.name = ' ' }
    
    it { should_not be_valid }
  end

  describe "name too long" do
    before { currency.name = 'n'*(Currency::NAME_LEN + 1) }
    
    it { should_not be_valid }
  end

  it "name not unique" do
    expect { FactoryGirl.create(:currency, :name => currency.name.upcase) }.to raise_exception(ActiveRecord::RecordInvalid)
  end

  describe "status (valid)" do
    Currency::VALID_STATUSES.each do |status|
      before { currency.status = status }
      
      it { should be_valid }
    end
  end

  describe "status (invalid)" do
    [3, 2.5, -1, 'abc', nil].each do |status|
      before { currency.status = status }
      
      it { should_not be_valid }
    end
  end
  
  describe "vouchers" do
    let(:currency) { FactoryGirl.create(:currency_with_vouchers) }
    
    it "should have vouchers" do
      expect(currency.vouchers.count).to eq(2)
    end
    
    describe "should not delete" do
      before { currency.destroy }
      
      it "should have errors" do
        expect(currency.errors.count).not_to eq(0)
      end
    end
    
    describe "Delete vouchers" do
      before { currency.vouchers.destroy_all }
      
      describe "Try again" do
        before { currency.destroy }
        
        it "should work" do
          expect(Currency.count).to eq(0)
        end
      end
    end
  end
end
