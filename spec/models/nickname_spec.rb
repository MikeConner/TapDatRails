# == Schema Information
#
# Table name: nicknames
#
#  id         :integer          not null, primary key
#  column     :integer          not null
#  word       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

describe Nickname do
  let(:nickname) { FactoryGirl.create(:nickname) }
  
  subject { nickname }
  
  it "should respond to everything" do
    expect(nickname).to respond_to(:column)
    expect(nickname).to respond_to(:word)  
  end
  
  it { should be_valid }
  
  describe "missing column" do
    before { nickname.column = nil }
    
    it { should_not be_valid }
  end
  
  describe "invalid column" do
    [-1, 0.5, 'abc'].each do |c|
      before { nickname.column = c }
      
      it { should_not be_valid }
    end
  end
  
  describe "Missing word" do
    before { nickname.word = ' ' }
    
    it { should_not be_valid }
  end
end
