# == Schema Information
#
# Table name: transaction_details
#
#  id              :integer          not null, primary key
#  transaction_id  :integer
#  subject_id      :integer          not null
#  target_id       :integer          not null
#  credit_satoshi  :integer
#  debit_satoshi   :integer
#  conversion_rate :decimal(, )      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class TransactionDetail < ActiveRecord::Base
  attr_accessible :conversion_rate, :credit_satoshi, :debit_satoshi, :subject_id, :target_id
  
  belongs_to :transaction
  
  validates_presence_of :subject_id
  validates_presence_of :target_id
  validates :conversion_rate, :numericality => { :greater_than => 0 }
  
  validate :has_amount
  
private
  def has_amount
    if self.credit_satoshi.nil? and self.debit_satoshi.nil?
      self.errors.add :base, I18n.t('invalid_transaction_amt')
    end
  end
end
