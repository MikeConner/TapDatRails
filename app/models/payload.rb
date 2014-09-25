# == Schema Information
#
# Table name: payloads
#
#  id         :integer          not null, primary key
#  nfc_tag_id :integer          not null
#  uri        :string(255)
#  content    :text
#  threshold  :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# CHARTER
#   Define the "reward" for tapping at or above a given threshold
#
# USAGE
#   
# NOTES AND WARNINGS
#   Content is either a URI or text (or both)
#
class Payload < ActiveRecord::Base
  attr_accessible :content, :threshold, :uri
  
  belongs_to :nfc_tag
  
  validates :threshold, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  
  validate :has_content
  
private
  def has_content
    if self.uri.blank? and self.content.blank?
      self.errors.add :base, I18n.t('empty_payload')
    end
  end
end
