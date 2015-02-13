# == Schema Information
#
# Table name: single_code_generators
#
#  id          :integer          not null, primary key
#  currency_id :integer
#  code        :string(32)       not null
#  start_date  :date
#  end_date    :date
#  value       :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#

class SingleCodeGenerator < ActiveRecord::Base
  belongs_to :currency
  
  MAX_CODE_LEN = 32
  
  validates :code, :presence => true, :uniqueness => true, :length => { :maximum => MAX_CODE_LEN }
  validates :value, :numericality => { :only_integer => true, :greater_than => 0 }
  validate :date_consistency
  
  def active?
    if self.start_date.nil? and self.end_date.nil?
      # If both nil, always valid
      true
    elsif self.start_date.nil?
      Date.today <= self.end_date
    elsif self.end_date.nil?
      Date.today >= self.start_date
    elsif (Date.today >= self.start_date) and (Date.today <= self.end_date)
      true
    else
      false
    end  
  end
  
private
  def date_consistency
    unless self.start_date.nil? or self.end_date.nil?
      if self.end_date < self.start_date
        self.errors.add :base, 'Inconsisent start/end dates'
      end
    end
  end
end
