# == Schema Information
#
# Table name: balances
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  amount          :integer          default(0), not null
#  expiration_date :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  currency_id     :integer
#

describe Balance do
  let(:user) { FactoryGirl.create(:user) }
  let(:currency) { FactoryGirl.create(:currency) }
  let(:balance) { FactoryGirl.create(:balance, :user => user, :currency => currency) }
  
  subject { balance }
  
  it "should respond to anything" do
    expect(balance).to respond_to(:amount)
    expect(balance).to respond_to(:expiration_date)
  end
  
  its(:user) { should be == user }
  its(:currency) { should be == currency }
  
  it { should be_valid }
  
  it "should have default amount initially" do
    expect(balance.amount).to eq(1000)
  end 
  
  describe "Invalid amount" do
    [-1, 0.5, 'abc'].each do |amount|
      before { balance.amount = amount }
      
      it { should_not be_valid }
    end
  end 
end
