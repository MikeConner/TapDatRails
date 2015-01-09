# == Schema Information
#
# Table name: bitcoin_rates
#
#  id         :integer          not null, primary key
#  rate       :float
#  created_at :datetime
#  updated_at :datetime
#

RSpec.describe BitcoinRate, :type => :model do
  let(:rate) { FactoryGirl.create(:bitcoin_rate) }
  
  subject { rate }
  
  it "should respond to everything" do
    expect(rate). to respond_to(:rate)
  end
  
  it { should be_valid }
  
  describe "Missing rate" do
    before { rate.rate = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Invalid rate" do
    ['abc', -5].each do |r|
      before { rate.rate = r }
      
      it { should_not be_valid }
    end
  end
  
  describe "More than one" do
    before { rate }
    
    describe "should not allow dups" do
       before do
         10.times do 
           FactoryGirl.create(:bitcoin_rate)
         end
       end
       
       it "should only have one" do
         expect(BitcoinRate.count).to eq(1)
       end
    end
  end
end
