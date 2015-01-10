# == Schema Information
#
# Table name: currencies
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  name              :string(24)       not null
#  icon              :string(255)
#  denominations     :string(255)
#  expiration_days   :integer
#  status            :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  reserve_balance   :integer          default(0), not null
#  icon_processing   :boolean
#  amount_per_dollar :integer          default(100), not null
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
# Currencies have icon images, and also a defined set of denominations. Vouchers issued in the currency have to be denominated
# to a valid value (this is also what the GUI uses to set tap amounts)
#
# NOTES AND WARNINGS
#   Currency objects are only used for non-bitcoin currencies. Bitcoin itself uses the former mechanism (i.e., satoshi_balance in the user)
#   Currency denominations are stored as serialized integer arrays. To show and edit, they have to be simple comma-delimited strings;
# hence the encode and decode methods.
#
class Currency < ActiveRecord::Base
  ACTIVE = 0
  INACTIVE = 1
  NAME_LEN = 24
  
  VALID_STATUSES = [ACTIVE, INACTIVE]
  
  mount_uploader :icon, ImageUploader
  process_in_background :icon

  belongs_to :user
  has_many :vouchers, :dependent => :restrict_with_error
  
  validates :expiration_days, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :name, :presence => true,
                   :length => { :maximum => NAME_LEN },
                   :uniqueness => { :case_sensitive => false }
  validates_inclusion_of :status, :in => VALID_STATUSES
  # Balance available to create vouchers (from external funding)
  validates :reserve_balance, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :amount_per_dollar, :numericality => { :only_integer => true, :greater_than => 0 }
  
  def conversion_rate
    1.0 / self.amount_per_dollar.to_f
  end
  
  def encode_denominations
    unless self.denominations.blank?
      begin
        d = self.denominations.split(',')
        numerics = []
        d.each do |c|
          numerics.push(c.to_i)
        end
        
        self.denominations = YAML::dump(numerics)
      rescue
        self.errors.add :base, "Invalid denominations #{self.denominations}"  
      end
    end
  end
  
  def decode_denominations(as_str = false)
    if self.denominations.blank?
      as_str ? "" : []
    else
      d = YAML.load(self.denominations)
      if as_str
        str = ""
        d.each do |n|
          str += ", " unless str.blank?
          str += n.to_s
        end
        
        str
      else
        d
      end
    end
  end
end
