# == Schema Information
#
# Table name: payloads
#
#  id         :integer          not null, primary key
#  nfc_tag_id :integer          not null
#  uri        :string(255)
#  content    :text
#  threshold  :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

describe Payload do
  let(:tag) { FactoryGirl.create(:nfc_tag) }
  let(:payload) { FactoryGirl.create(:payload, :nfc_tag => tag) }
  
  subject { payload }
  
  it "should respond to everything" do
    payload.should respond_to(:uri)
    payload.should respond_to(:content)  
    payload.should respond_to(:threshold)  
  end
  
  its(:nfc_tag) { should be == tag }
  it { should be_valid }
  
  describe "invalid threshold" do
    [-1, 0.5, 'abc', nil].each do |threshold|
      before { payload.threshold = threshold }
      
      it { should_not be_valid }
    end
  end

  describe "no content" do
    before do
      payload.uri = ' '
      payload.content = ' '
    end
    
    it { should_not be_valid }
  end
end
