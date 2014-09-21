# == Schema Information
#
# Table name: nfc_tags
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  name             :string(255)
#  tag_id           :string(255)      not null
#  lifetime_balance :integer          default(0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

describe NfcTag do
  let(:user) { FactoryGirl.create(:user) }
  let(:tag) { FactoryGirl.create(:nfc_tag, :user => user) }
  
  subject { tag }
  
  it "should respond to everything" do
    tag.should respond_to(:name)
    tag.should respond_to(:tag_id)  
    tag.should respond_to(:lifetime_balance)  
  end
  
  its(:user) { should be == user }
  it { should be_valid }
  
  describe "missing tag id" do
    before { tag.tag_id = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "invalid balance" do
    [-1, 0.5, 'abc', nil].each do |balance|
      before { tag.lifetime_balance = balance }
      
      it { should_not be_valid }
    end
  end

  describe "payloads" do
    let(:tag) { FactoryGirl.create(:nfc_tag_with_payloads) }
    
    it "should have payloads" do
      tag.payloads.count.should be == 3
    end
    
    describe "destroy" do
      before { tag.destroy }
      
      it "should be gone" do
        Payload.count.should be == 0
      end
    end
  end  
end
