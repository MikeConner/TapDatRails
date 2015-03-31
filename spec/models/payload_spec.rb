# == Schema Information
#
# Table name: payloads
#
#  id                       :integer          not null, primary key
#  nfc_tag_id               :integer          not null
#  uri                      :string(255)
#  content                  :text
#  threshold                :integer          default(0), not null
#  created_at               :datetime
#  updated_at               :datetime
#  payload_image            :string(255)
#  slug                     :string(255)
#  mobile_payload_image_url :string(255)
#  mobile_payload_thumb_url :string(255)
#  content_type             :string(16)       default("image"), not null
#  payload_image_processing :boolean
#  description              :string(255)
#

describe Payload do
  let(:tag) { FactoryGirl.create(:nfc_tag) }
  let(:payload) { FactoryGirl.create(:payload, :nfc_tag => tag) }
  
  subject { payload }
  
  it "should respond to everything" do
    expect(payload).to respond_to(:uri)
    expect(payload).to respond_to(:payload_image)
    expect(payload).to respond_to(:content)  
    expect(payload).to respond_to(:threshold)  
    expect(payload).to respond_to(:slug)  
    expect(payload).to respond_to(:description)  
    expect(payload).to respond_to(:mobile_payload_image_url)
    expect(payload).to respond_to(:mobile_payload_thumb_url)
    expect(payload).to respond_to(:content_type)
    expect(payload).to respond_to(:payload_image_processing)
  end
 
  its(:nfc_tag) { should be == tag }
  it { should be_valid }
  
  describe "Content type missing" do
    before { payload.content_type = ' ' }
    
    it { should_not be_valid }
  end

  describe "Description missing" do
    before { payload.description = ' ' }
    
    it { should_not be_valid }
  end

  it "should have default image type" do
    expect(Payload::VALID_CONTENT_TYPES.include?(payload.content_type)).to be true
  end
 
  describe "Content type (valid)" do
    Payload::VALID_CONTENT_TYPES.each do |sample|
      before { payload.content_type = sample }
      
      it { should be_valid }
    end
  end
  
  describe "Invalid content type" do
    before { payload.content_type = 'Not a valid type' }
    
    it { should_not be_valid }
  end
  
  describe "Missing threshold" do
    before { payload.threshold = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "invalid threshold" do
    [-1, 0.5, 'abc'].each do |threshold|
      before { payload.threshold = threshold }
      
      it { should_not be_valid }
    end
  end
  
  it "should have a slug" do
    expect(payload.slug).to_not be_nil
  end  
  
  describe "no content" do
    before do
      payload.uri = ' '
      payload.content = ' '
    end
    
    it { should_not be_valid }
  end
end
