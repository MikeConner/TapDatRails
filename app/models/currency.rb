# == Schema Information
#
# Table name: currencies
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  name            :string(24)       not null
#  icon            :string(255)
#  denominations   :string(255)
#  expiration_days :integer
#  status          :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

# CHARTER
#   Represent a non-bitcoin currency associated with an issuing user. Users can issue durable currencies (e.g., museums), or
# one-off "event" currencies. 
#
# USAGE
#   Each currency has an expiration_days policy (e.g., 30 means they expire 30 days after assignment to a "customer" user)
# The issuer can expire all outstanding vouchers at once by setting the entire currency status to INACTIVE.
# 
# Currencies have icon images, and also a defined set of denominations. Vouchers issued in the currency have to be denominated
# to a valid value (this is also what the GUI uses to set tap amounts)
#
# NOTES AND WARNINGS
#   Currency objects are only used for non-bitcoin currencies. Bitcoin itself uses the former mechanism (i.e., satoshi_balance in the user)
#
class Currency < ActiveRecord::Base
  ACTIVE = 0
  INACTIVE = 1
  NAME_LEN = 24
  
  VALID_STATUSES = [ACTIVE, INACTIVE]
  
  mount_uploader :icon, ImageUploader

  attr_accessible :denominations, :expiration_days, :icon, :remote_icon_url, :name, :status, :user_id
  
  belongs_to :user
  has_many :vouchers, :dependent => :restrict
  
  validates :expiration_days, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :name, :presence => true,
                   :length => { :maximum => NAME_LEN },
                   :uniqueness => { :case_sensitive => false }
  validates_inclusion_of :status, :in => VALID_STATUSES
end
