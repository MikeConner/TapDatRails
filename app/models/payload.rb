# == Schema Information
#
# Table name: payloads
#
#  id                       :integer          not null, primary key
#  nfc_tag_id               :integer          not null
#  uri                      :string(255)
#  content                  :text
#  threshold                :integer          default(0), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  payload_image            :string(255)
#  payload_thumb            :string(255)
#  slug                     :string(255)
#  mobile_payload_image_url :string(255)
#  mobile_payload_thumb_url :string(255)
#

# CHARTER
#   Define the "reward" for tapping at or above a given threshold
#
# USAGE
#   
# NOTES AND WARNINGS
#   Content is either an image/thumbnail pair, Uri or text (or a combination). 
# The URI field is reserved for non-image content (like an MP3 or regular URL).
#
class Payload < ActiveRecord::Base
  extend FriendlyId
  friendly_id :generate_id, use: [:slugged, :history]
  
  attr_accessible :content, :threshold, :uri, :payload_image, :remote_payload_image_url, :payload_thumb, :remote_payload_thumb_url,
                  :mobile_payload_image_url, :mobile_payload_thumb_url

  mount_uploader :payload_image, ImageUploader
  mount_uploader :payload_thumb, ImageUploader

  belongs_to :nfc_tag
  
  validates :threshold, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  
  validate :has_content
  
private
  def has_content
    if self.uri.blank? and self.content.blank?
      self.errors.add :base, I18n.t('empty_payload')
    end
  end
  
  def generate_id
    SecureRandom.uuid
  end
end
