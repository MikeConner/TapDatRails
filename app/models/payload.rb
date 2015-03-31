# == Schema Information
#
# Table name: payloads
#
#  id                       :integer          not null, primary key
#  nfc_tag_id               :integer          not null
#  uri                      :string(255)
#  content                  :text
#  threshold                :integer          default(0), not null
#  created_at               :datetime
#  updated_at               :datetime
#  payload_image            :string(255)
#  slug                     :string(255)
#  mobile_payload_image_url :string(255)
#  mobile_payload_thumb_url :string(255)
#  content_type             :string(16)       default("image"), not null
#  payload_image_processing :boolean
#  description              :string(255)
#

# CHARTER
#   Define the "reward" for tapping at or above a given threshold
#
# USAGE
#   uri content can be: audio, video, url, text, image coupon: server validates
#
# NOTES AND WARNINGS
#   Content is either an image/thumbnail pair, Uri or text (or a combination).
# The URI field is reserved for non-image content (like an MP3 or regular URL).
#
class Payload < ActiveRecord::Base
  extend FriendlyId
  friendly_id :generate_id, use: [:slugged, :history, :finders]

  VALID_CONTENT_TYPES = ['image', 'audio', 'video', 'url', 'text', 'coupon']

  mount_uploader :payload_image, ImageUploader
  process_in_background :payload_image

  belongs_to :nfc_tag

  validates :threshold, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :content_type, :inclusion => { :in => VALID_CONTENT_TYPES }
  validates_presence_of :description

  validate :has_content

private
  def has_content
    if self.uri.blank? and self.content.blank? and !self.payload_image.present? and self.mobile_payload_image_url.blank?
      self.errors.add :base, I18n.t('empty_payload')
    end
  end

  def generate_id
    SecureRandom.uuid
  end
end
