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
    expect(balance).to respond_to(:currency_name)
    expect(balance).to respond_to(:amount)
    expect(balance).to respond_to(:expiration_date)
  end
  
  its(:user) { should be == user }
  
  it { should be_valid }
  
  describe "missing name" do
    before { balance.currency_name = ' ' }
    
    it { should_not be_valid }
  end
  
  it "should have zero amount initially" do
    expect(balance.amount).to eq(0)
  end  
end
