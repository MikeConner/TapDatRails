# == Schema Information
#
# Table name: transaction_details
#
#  id              :integer          not null, primary key
#  transaction_id  :integer
#  subject_id      :integer          not null
#  target_id       :integer          not null
#  credit          :integer
#  debit           :integer
#  conversion_rate :decimal(, )      not null
#  created_at      :datetime
#  updated_at      :datetime
#  currency        :string(16)       default("USD"), not null
#

# CHARTER
#   Implement double-entry bookkeeping for transactions
#
# USAGE
#   Record debits or credits (in Satoshi), between users, within a transaction. Also record the 
# exchange rate used if the original currency was dollars.
#
# NOTES AND WARNINGS
#
class TransactionDetail < ActiveRecord::Base
  MAX_CURRENCY_LEN = 16
  CURRENCY_USD = 'USD'
  
  belongs_to :tap_transaction, :foreign_key => :transaction_id
  
  validates_presence_of :subject_id
  validates_presence_of :target_id
  validates :conversion_rate, :numericality => { :greater_than => 0 }
  validates :currency, :presence => true, :length => { :maximum => MAX_CURRENCY_LEN }
  
  validate :has_amount
  
private
  def has_amount
    if self.credit.nil? and self.debit.nil?
      self.errors.add :base, I18n.t('invalid_transaction_amt')
    end
  end
end
