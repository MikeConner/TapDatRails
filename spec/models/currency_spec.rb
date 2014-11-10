# == Schema Information
#
# Table name: currencies
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  name            :string(24)       not null
#  icon            :string(255)
#  denominations   :string(255)
#  expiration_days :integer
#  status          :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

describe Currency do
  let(:user) { FactoryGirl.create(:user) }
  let(:currency) { FactoryGirl.create(:currency, :user => user) }
  
  subject { currency }
  
  it "should respond to everything" do
    currency.should respond_to(:name)
    currency.should respond_to(:icon)
    currency.should respond_to(:remote_icon_url)
    currency.should respond_to(:denominations)
    currency.should respond_to(:expiration_days)
    currency.should respond_to(:status)
  end
  
  its(:user) { should be == user }
  
  it { should be_valid }
  
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
      currency.vouchers.count.should be == 2
    end
    
    it "should not delete" do
      expect { currency.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
    end
    
    describe "Delete vouchers" do
      before { currency.vouchers.destroy_all }
      
      describe "Try again" do
        before { currency.destroy }
        
        it "should work" do
          Currency.count.should be == 0
        end
      end
    end
  end
end
