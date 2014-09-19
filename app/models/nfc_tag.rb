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
#

class NfcTag < ActiveRecord::Base
  attr_accessible :lifetime_balance, :name, :tag_id,
                  :user_id
  
  belongs_to :user
  
  has_many :payloads, :dependent => :destroy
end
