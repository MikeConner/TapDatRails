# == Schema Information
#
# Table name: vouchers
#
#  id              :integer          not null, primary key
#  currency_id     :integer
#  user_id         :integer
#  uid             :string(16)       not null
#  amount          :integer          not null
#  status          :integer          default(0), not null
#  created_at      :datetime
#  updated_at      :datetime
#  expiration_date :date
#

describe Voucher do
 let(:currency) { FactoryGirl.create(:currency) }
 let(:user) { FactoryGirl.create(:user) }
 let(:voucher) { FactoryGirl.create(:assigned_voucher, :currency => currency, :user => user) }
 
 subject { voucher }
 
 it "should respond to everything" do
   expect(voucher).to respond_to(:uid)
   expect(voucher).to respond_to(:amount)
   expect(voucher).to respond_to(:status)
   expect(voucher).to respond_to(:expiration_date)
 end
 
 its(:currency) { should be == currency }
 its(:user) { should be == user }
 
 it { should be_valid }
 
 describe "missing status" do
   before { voucher.status = ' ' }
   
   it { should_not be_valid }
 end

 describe "invalid status" do
   before { voucher.status = 72 }
   
   it { should_not be_valid }
 end

 describe "missing amount" do
   before { voucher.amount = ' ' }
   
   it { should_not be_valid }
 end

 describe "missing uid" do
   before { voucher.uid = ' ' }
   
   it { should_not be_valid }
 end

 describe "uid too long" do
   before { voucher.uid = '*'*(Voucher::UID_LEN + 1) }
   
   it { should_not be_valid }
 end
 
 describe "un assigned" do
   let(:voucher) { FactoryGirl.create(:voucher, :currency => currency) }
   
   its(:currency) { should be == currency }
   its(:user) { should be_nil }
 end
 
 describe "statuses" do
   before do
     voucher
     @voucher2 = FactoryGirl.create(:voucher, :status => Voucher::EXPIRED)
   end
   
   it "should respond to the scope" do
     expect(Voucher.count).to eq(2)
     expect(Voucher.active.count).to eq(1)
   end
  end
end
