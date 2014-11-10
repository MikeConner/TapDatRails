# == Schema Information
#
# Table name: nfc_tags
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  name             :string(255)
#  tag_id           :string(255)      not null
#  lifetime_balance :integer          default(0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  currency_id      :integer
#

# CHARTER
#   Represent an NFC Tag.
#
# USAGE
#   Each tag has an opaque (and unique) tag_id. lifetime_balance is the cumulative total of all taps,
# which is an indicator of usage (not intended to be strictly audited). Each tag has one or more Payloads,
# which are the responses to taps. Higher tips mean more valuable Payloads, if so configured.
#
# NOTES AND WARNINGS
#   legible_id makes it easier for users to type in
#
class NfcTag < ActiveRecord::Base
  attr_accessible :lifetime_balance, :name, :tag_id,
                  :user_id, :currency_id
  
  belongs_to :user
  # If a non-BTC tag
  belongs_to :currency
  
  has_many :payloads, :dependent => :destroy
  
  validates_presence_of :tag_id
  validates :lifetime_balance, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  
  # Make the id look like a phone number, if possible
  def legible_id
    10 == self.tag_id.length ? "#{self.tag_id[0..2]}-#{self.tag_id[3..5]}-#{self.tag_id[6..9]}" : self.tag_id
  end
  
  def find_payload(amount)
    # Return a payload given an amount (by threshold)
    result = self.payloads.order(:threshold).first
    
    self.payloads.order('threshold DESC').each do |payload|
      if amount >= payload.threshold
        result = payload
        break
      end
    end
    
    result
  end
end
