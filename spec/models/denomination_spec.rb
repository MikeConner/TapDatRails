# == Schema Information
#
# Table name: denominations
#
#  id               :integer          not null, primary key
#  currency_id      :integer
#  value            :integer
#  image            :string(255)
#  image_processing :boolean
#  caption          :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

describe Denomination do
  let(:currency) { FactoryGirl.create(:currency) }
  let(:denomination) { FactoryGirl.create(:denomination, :currency => currency) }
  
  subject { denomination }
  
  it "should respond to everything" do
    expect(denomination).to respond_to(:value)
    expect(denomination).to respond_to(:caption)
    expect(denomination).to respond_to(:image)
    expect(denomination).to respond_to(:remote_image_url)
  end
  
  its(:currency) { should be == currency }
  
  it { should be_valid }
end
