# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  name                   :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  authentication_token   :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  phone_secret_key       :string(16)       not null
#  inbound_btc_address    :string(255)
#  outbound_btc_address   :string(255)
#  satoshi_balance        :integer          default(0), not null
#  profile_image          :string(255)
#  profile_thumb          :string(255)
#

# CHARTER
#   Encapsulate a TapDat user (web or mobile)
#
# USAGE
#  There is a 16-character phone secret key, which needs to be generated on the phone and passed in. Upon success, devise will generate
# an authentication token.
#
# NOTES AND WARNINGS
#   Authenticates by token, through devise (not email/password). Email can be set by the user, but defaults to an auto-generated one
# in a fake "UNKNOWN_EMAIL_DOMAIN". 
#
class User < ActiveRecord::Base
  include ApplicationHelper

  before_save :ensure_authentication_token
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  # SNL Skit; Google it
  UNKNOWN_EMAIL_DOMAIN = '@clownpenis.fart'
  SECRET_KEY_LEN = 16

  mount_uploader :profile_image, ImageUploader
  mount_uploader :profile_thumb, ImageUploader
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, 
                  :inbound_btc_address, :outbound_btc_address, :phone_secret_key,
                  :profile_image, :remote_profile_image_url, :profile_thumb, :remote_profile_thumb_url   
                  
  has_many :nfc_tags, :dependent => :destroy
  has_many :transactions, :dependent => :restrict 
  has_many :transaction_details, :through => :transactions   
  
  validates :email, :uniqueness => { case_sensitive: false },
                    :format => { with: EMAIL_REGEX }
  validates_presence_of :name
  validates :phone_secret_key, :presence => true, :length => { :maximum => SECRET_KEY_LEN }
  validates :satoshi_balance, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }         
end
