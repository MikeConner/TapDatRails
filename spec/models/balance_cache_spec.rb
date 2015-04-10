# == Schema Information
#
# Table name: balance_caches
#
#  id          :integer          not null, primary key
#  btc_address :string(36)       not null
#  satoshi     :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#

describe BalanceCache do
  let(:cache) { FactoryGirl.create(:balance_cache) }
  
  subject { cache }
  
  it "should respond to everything" do
    expect(cache).to respond_to(:btc_address)
    expect(cache).to respond_to(:satoshi)
  end
  
  it { should be_valid }
  
  describe "missing address" do
    before { cache.btc_address = ' ' } 
    
    it { should_not be_valid }
  end

  describe "address too long" do
    before { cache.btc_address = '*'*37 } 
    
    it { should_not be_valid }
  end

  describe "address invalid" do
    before { cache.btc_address = '7CXo82SC7zhbbYdWzUChLQWZB4ryqZJ3vk' } 
    
    it { should_not be_valid }
  end
  
  describe "Missing balance" do
    before { cache.satoshi = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Invalid balance" do
    [-1, 0.5, 'abc'].each do |balance|
      before { cache.satoshi = balance }
      
      it { should_not be_valid }
    end
  end
end
