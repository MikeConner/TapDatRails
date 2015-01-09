# == Schema Information
#
# Table name: vouchers
#
#  id          :integer          not null, primary key
#  currency_id :integer
#  user_id     :integer
#  uid         :string(16)       not null
#  amount      :integer          not null
#  status      :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

# CHARTER
#   Currency issuers generate Vouchers as a store of value for their proprietary currency. 
#
# USAGE
#   Vouchers are issued in one of the valid denominations.
#   The expiration date gets bumped up to the expiration date of the voucher (as determined by the expiration_days field in the associated currency)
# If there are any active vouchers in this balance at the time a new one is added or a tap is attempted, and the date is passed, all the existing vouchers
# are marked expired. Also, the currency owner can set a currency to inactive (e.g., when the event is over), which automatically expires all associated
# active vouchers.
#
# NOTES AND WARNINGS
#   When they are purchased by customers (venues handle all the actual money), they're scanned/typed into the customer's phone, which assigns the
# voucher to that customer. If there are existing vouchers that expire before the current date, they are expired, and
# the expiration date of the balance is now set a number of days in the future corresponding to the currency's expiration policy.
#
class Voucher < ActiveRecord::Base
  ACTIVE = 0
  REDEEMED = 1
  EXPIRED = 2
  UID_LEN = 16
  
  STATUSES = [ACTIVE, REDEEMED, EXPIRED]
  
  before_validation :ensure_uid
  before_validation :ensure_valid_denomination, :on => :create
  
  belongs_to :currency
  belongs_to :user
  
  validates_presence_of :amount, :uid
  validates_inclusion_of :status, :in => STATUSES
  validates :uid, :presence => true,
                  :length => { :maximum => UID_LEN }
  validates :amount, :presence => true,
                     :numericality => { :only_integer => true, :greater_than => 0 }
  
  scope :active, -> { where("status = ?", ACTIVE) }
  
  # For display
  def display_status
    case self.status
    when ACTIVE
      "Active"
    when REDEEMED
      "Redeemed"
    when EXPIRED
      "Expired"
    else
      raise "Unknown status #{self.status}"
    end
  end   
  
  # For display
  def assigned_user_display
    if self.user.nil?
      "N/A"
    else
      self.user.name
    end
  end   
               
private
  def ensure_uid
    self.uid = SecureRandom.hex(3) if self.uid.nil?
  end
  
  def ensure_valid_denomination
    unless self.currency.denominations.nil?
      valid_denominations = YAML.load(self.currency.denominations)
      
      unless valid_denominations.include?(self.amount)
        self.errors.add :base, "Invalid denomination #{self.amount}"
      end
    end
  end  
end
