# == Schema Information
#
# Table name: transactions
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  nfc_tag_id     :integer
#  payload_id     :integer
#  dest_id        :integer
#  satoshi_amount :integer
#  dollar_amount  :integer
#  comment        :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Transaction < ActiveRecord::Base
  attr_accessible :comment, :dest_id, :dollar_amount, :satoshi_amount, :source_id
  
  belongs_to :user
  belongs_to :nfc_tag
  belongs_to :payload
  
  has_many :transaction_details, :dependent => :destroy
  
  validates_presence_of :user_id
  validates_presence_of :dest_id
  validates :satoshi_amount, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, :allow_nil => true
  validates :dollar_amount, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, :allow_nil => true
  
  validate :has_amount

private
  def has_amount
    if self.satoshi_amount.nil? and self.dollar_amount.nil?
      self.errors.add :base, I18n.t('invalid_transaction_amt')
    end
  end
end
