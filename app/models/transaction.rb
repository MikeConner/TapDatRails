# == Schema Information
#
# Table name: transactions
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  nfc_tag_id    :integer
#  payload_id    :integer
#  dest_id       :integer
#  amount        :integer
#  dollar_amount :integer
#  comment       :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  slug          :string(255)
#  voucher_id    :integer
#

# CHARTER
#   Summary record of a transaction, bitcoin or currency
#
# USAGE
#   Details are recorded in a separate dependent model (credits and debits). If the currency id is blank, it's bitcoin. Otherwise it's a currency
#   
# NOTES AND WARNINGS
#   Owner of the transaction is the destination
#
#   TYPES OF TRANSACTIONS AND FIELD DEFINITIONS
# Funding transaction - adding to reserve balance (or, rarely, adjusting it). Only admins can do this
#   Owner is the user receiving the funds
#   src_id is 0, since it comes from us
#   amount is the difference (or zero if it's negative)
#   comment describes what happened exactly
#
class Transaction < ActiveRecord::Base
  extend FriendlyId
  friendly_id :generate_id, use: [:slugged, :history, :finders]
  
  belongs_to :user
  belongs_to :nfc_tag
  belongs_to :payload
  # foreign key to reference a redeemed (possibly single code) voucher
  belongs_to :voucher
  
  has_many :transaction_details, :dependent => :destroy
  
  validates_presence_of :user_id
  validates_presence_of :dest_id
  validates :amount, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, :allow_nil => true
  validates :dollar_amount, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, :allow_nil => true
  
  validate :has_amount

private
  def has_amount
    if self.amount.nil? and self.dollar_amount.nil?
      self.errors.add :base, I18n.t('invalid_transaction_amt')
    end
  end
  
  def generate_id
    SecureRandom.uuid
  end
end
