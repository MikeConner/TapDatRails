# == Schema Information
#
# Table name: balances
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  currency_name   :string(255)      not null
#  amount          :integer          default(0), not null
#  expiration_date :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

describe Balance do
  let(:user) { FactoryGirl.create(:user) }
  let(:balance) { FactoryGirl.create(:balance, :user => user) }
  
  subject { balance }
  
  it "should respond to anything" do
    balance.should respond_to(:currency_name)
    balance.should respond_to(:amount)
    balance.should respond_to(:expiration_date)
  end
  
  its(:user) { should be == user }
  
  it { should be_valid }
  
  describe "missing name" do
    before { balance.currency_name = ' ' }
    
    it { should_not be_valid }
  end
  
  it "should have zero amount initially" do
    balance.amount.should be == 0
  end
  
  describe "vouchers" do
    let(:balance) { FactoryGirl.create(:balance_with_vouchers, :user => user) }
    
    it "should have vouchers" do
      balance.vouchers.count.should be == 3
    end
    
    it "should get the right amount" do
      balance.amount.should be == Voucher.sum(:amount)
    end
    
    describe "delete" do
      before { balance.destroy }
      
      it "should be gone" do
        Voucher.count.should be == 0
      end
    end
  end
end
