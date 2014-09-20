# == Schema Information
#
# Table name: opportunities
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)      not null
#  location   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

describe Opportunity do  
  let(:opportunity) { FactoryGirl.create(:opportunity) }
  
  subject { opportunity }
  
  it "should respond to everything (instant)" do
    opportunity.should respond_to(:name)
    opportunity.should respond_to(:email)
    opportunity.should respond_to(:location)
  end
  
  it { should be_valid }
  
  describe "Missing email" do
    before { opportunity.email = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Valid emails" do
    ApplicationHelper::VALID_EMAILS.each do |email|
      before { opportunity.email = email }
      
      it { should be_valid }
    end
  end

  describe "Invalid emails" do
    ApplicationHelper::INVALID_EMAILS.each do |email|
      before { opportunity.email = email }
      
      it { should_not be_valid }
    end
  end
end
