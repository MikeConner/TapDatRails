# == Schema Information
#
# Table name: single_code_generators
#
#  id          :integer          not null, primary key
#  currency_id :integer
#  code        :string(32)       not null
#  start_date  :date
#  end_date    :date
#  value       :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#

describe SingleCodeGenerator do
  let(:currency) { FactoryGirl.create(:currency) }
  let(:generator) { FactoryGirl.create(:single_code_generator, :currency => currency) }
  
  it "should respond to everything" do
    expect(generator).to respond_to(:code)
    expect(generator).to respond_to(:start_date)
    expect(generator).to respond_to(:end_date)
    expect(generator).to respond_to(:value)
  end
  
  it "should be valid" do
    expect(generator).to be_valid
  end
  
  it "should have the right parent" do
    expect(generator.currency).to eq(currency)
  end
  
  describe "Missing code" do
    before { generator.code = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Should not allow duplicate code" do
    before { @new_generator = FactoryGirl.create(:single_code_generator) }
    
    describe "should fail" do
      before { @new_generator.code = generator.code }
      
      it "should be invalid" do
        expect(@new_generator).to_not be_valid
      end
    end
  end
  
  describe "Missing value" do
    before { generator.value = ' ' }
    
    it { should_not be_valid } 
  end
  
  describe "Invalid value" do
    [0, 0.5, -1, 'abc'].each do |value|
      before { generator.value = value }
      
      it { should_not be_valid }
    end
  end
  
  describe "Inconsistent dates" do
    before do
      generator.start_date = 6.months.ago
      generator.end_date = 1.year.ago
    end
    
    it "should not be valid" do
      expect(generator).to_not be_valid
    end 
  end
  
  describe "generators" do
    let(:currency) { FactoryGirl.create(:currency_with_generators) }
    
    it "should have a couple generators" do
      expect(currency.single_code_generators.count).to eq(2)
    end
    
    describe "Try to delete" do
      before { currency.destroy }
      
      it "should succeed" do
        expect(SingleCodeGenerator.count).to eq(0)
      end
    end
  end
end
