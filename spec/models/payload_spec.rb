# == Schema Information
#
# Table name: payloads
#
#  id            :integer          not null, primary key
#  nfc_tag_id    :integer          not null
#  uri           :string(255)
#  content       :text
#  threshold     :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  payload_image :string(255)
#  payload_thumb :string(255)
#  slug          :string(255)
#

describe Payload do
  let(:tag) { FactoryGirl.create(:nfc_tag) }
  let(:payload) { FactoryGirl.create(:payload, :nfc_tag => tag) }
  
  subject { payload }
  
  it "should respond to everything" do
    payload.should respond_to(:uri)
    payload.should respond_to(:payload_image)
    payload.should respond_to(:payload_thumb)
    payload.should respond_to(:content)  
    payload.should respond_to(:threshold)  
    payload.should respond_to(:slug)  
    payload.should respond_to(:mobile_payload_image_url)
    payload.should respond_to(:mobile_payload_thumb_url)
  end
  
  its(:nfc_tag) { should be == tag }
  it { should be_valid }
  
  describe "invalid threshold" do
    [-1, 0.5, 'abc', nil].each do |threshold|
      before { payload.threshold = threshold }
      
      it { should_not be_valid }
    end
  end
  
  it "should have a slug" do
    payload.slug.should_not be_nil
  end  
  
  describe "no content" do
    before do
      payload.uri = ' '
      payload.content = ' '
    end
    
    it { should_not be_valid }
  end
end
