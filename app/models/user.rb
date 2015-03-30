# == Schema Information
#
# Table name: users
#
#  id                            :integer          not null, primary key
#  email                         :string(255)      default(""), not null
#  encrypted_password            :string(255)      default(""), not null
#  name                          :string(255)      default(""), not null
#  reset_password_token          :string(255)
#  reset_password_sent_at        :datetime
#  remember_created_at           :datetime
#  sign_in_count                 :integer          default(0)
#  current_sign_in_at            :datetime
#  last_sign_in_at               :datetime
#  current_sign_in_ip            :string(255)
#  last_sign_in_ip               :string(255)
#  authentication_token          :string(255)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  phone_secret_key              :string(16)       not null
#  inbound_btc_address           :string(255)
#  outbound_btc_address          :string(255)
#  satoshi_balance               :integer          default(0), not null
#  profile_image                 :string(255)
#  mobile_profile_image_url      :string(255)
#  mobile_profile_thumb_url      :string(255)
#  inbound_btc_qrcode            :string(255)
#  role                          :integer          default(0), not null
#  slug                          :string(255)
#  profile_image_processing      :boolean
#  inbound_btc_qrcode_processing :boolean
#

require 'nickname_generator'

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
  extend FriendlyId
  friendly_id :generate_slug, use: [:slugged, :history, :finders]
  
  include ApplicationHelper

  before_save :ensure_authentication_token!

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  UNKNOWN_EMAIL_DOMAIN = '@noreply.fish'
  SECRET_KEY_LEN = 16
  # User Roles (bitmask, if we need more than one)
  # Wimping out and not using Devise mechanisms
  ADMIN_ROLE = 1
  
  mount_uploader :profile_image, ImageUploader
  mount_uploader :inbound_btc_qrcode, ImageUploader
  process_in_background :profile_image
  process_in_background :inbound_btc_qrcode
                    
  has_many :nfc_tags, :dependent => :destroy
  has_many :transactions, :dependent => :restrict_with_error 
  has_many :transaction_details, :through => :transactions   
  has_many :currencies, :dependent => :destroy
  has_many :balances, :dependent => :destroy
  has_many :vouchers, :dependent => :restrict_with_error 
  has_many :payloads, -> { uniq }, :through => :transactions
  
  validates :email, :uniqueness => { case_sensitive: false },
                    :format => { with: EMAIL_REGEX },
                    :allow_blank => true
  validates_presence_of :name
  validates :phone_secret_key, :presence => true, :length => { :maximum => SECRET_KEY_LEN }
  validates :satoshi_balance, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }  
  
  def generated_email?
    self.email.ends_with?(UNKNOWN_EMAIL_DOMAIN)
  end  
  
  def admin?
    1 == (self.role & ADMIN_ROLE)
  end
  
  def currency_balance(currency)
    balance = balances.where(:currency_id => currency.id).first rescue nil
    
    balance.nil? ? 0 : balance.amount
  end
  
  def reset_password
    pwd = NicknameGenerator.generate_nickname.gsub(/ /, '_') + '_' + SecureRandom.hex(2)
    self.password = pwd
    if save
      UserMailer.delay.welcome_email(self, pwd)
    end
  end
  
protected
  def ensure_authentication_token!
    if self.authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def generate_authentication_token
    loop do
      token = generate_secure_token_string
      break token unless User.where(:authentication_token => token).first
    end
  end
     
  def generate_secure_token_string
    SecureRandom.urlsafe_base64(25).tr('lIO0', 'sxyz')
  end
  
private
  def generate_slug
    SecureRandom.uuid
  end
end
