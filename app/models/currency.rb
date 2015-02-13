# == Schema Information
#
# Table name: currencies
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  name              :string(24)       not null
#  icon              :string(255)
#  expiration_days   :integer
#  status            :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  reserve_balance   :integer          default(0), not null
#  icon_processing   :boolean
#  amount_per_dollar :integer          default(100), not null
#  symbol            :string(1)
#  max_amount        :integer          default(500), not null
#

# CHARTER
#   Represent a non-bitcoin currency associated with an issuing user. Users can issue durable currencies (e.g., museums), or
# one-off "event" currencies. 
#
# USAGE
#   Only admins can create currencies (for regular users). They can also edit the reserve amount (which generates a transaction).
#   The currency issuing users can then generate vouchers in any amount consistent with the denominations, which decrements their
# reserve balance.
#
#   Each currency has an expiration_days policy (e.g., 30 means they expire 30 days after assignment to a "customer" user)
# The issuer can expire all outstanding vouchers at once by setting the entire currency status to INACTIVE.
# 
# Currencies have icon images, single-character symbols, and also a defined set of denominations (with associated images). 
#   Vouchers issued in the currency have to be denominated to a valid value (this is also what the GUI uses to set tap amounts)
#
# NOTES AND WARNINGS
#   Currency objects are only used for non-bitcoin currencies. Bitcoin itself uses the former mechanism (i.e., satoshi_balance in the user)
#   Currency denominations are stored as dependent models
#   Allow 0 in max amount (perhaps indicating no limit?)
#
class Currency < ActiveRecord::Base
  ACTIVE = 0
  INACTIVE = 1
  NAME_LEN = 24
  # Max "Tip" per transaction for this currency
  MAX_AMOUNT = 500 
  
  VALID_STATUSES = [ACTIVE, INACTIVE]
  
  mount_uploader :icon, ImageUploader
  process_in_background :icon

  belongs_to :user
  has_many :vouchers, :dependent => :restrict_with_error
  has_many :denominations, :dependent => :destroy
  has_many :single_code_generators, :dependent => :destroy
  
  accepts_nested_attributes_for :denominations, :allow_destroy => true, 
                                :reject_if => :reject_denominations
  accepts_nested_attributes_for :single_code_generators, :allow_destroy => true
  
  validates :expiration_days, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :name, :presence => true,
                   :length => { :maximum => NAME_LEN },
                   :uniqueness => { :case_sensitive => false }
  validates_inclusion_of :status, :in => VALID_STATUSES
  # Balance available to create vouchers (from external funding)
  validates :reserve_balance, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :amount_per_dollar, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :symbol, :length => { :is => 1 }, :allow_blank => true
  validates :max_amount, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => MAX_AMOUNT }
  
  def active_generators
    generators = []
    
    single_code_generators.each do |generator|
      generators.push(generator) if generator.active?
    end
    
    generators
  end
  
  def conversion_rate
    1.0 / self.amount_per_dollar.to_f
  end  
  
  def denomination_values
    denominations.map { |d| d.value }
  end
  
private
  def reject_denominations(attributes)
    # Reject if no changes, so that we're not uploading every single piece of content every time, even if nothing changed. That would get expensive.
    # Note this will not stop it from uploading unchanged images if they change the caption, but it's at least an improvement until we find something better
    # Strategy is to look up find the original record, then compare each attribute to the current value, setting a flag if anything changed
    current = self.denominations.where(:id => attributes['id']).first
    if current.nil?
      changed = true
    else
      changed = false
      
      attributes.each do |k, v|
        next if k == '_destroy'
        
        unless current[k].to_s == v
          changed = true
          break
        end
      end
    end
    
    # Return true (reject record) if all_blank or unchanged
    if changed
      # All blank logic (same as reject_if :all_blank)
      attributes.all? { |key, value| key == '_destroy' || value.blank? }
    else
      true
    end
  end  
end
