module ApplicationHelper
  EMAIL_REGEX = /\A\w.*?@\w.*?\.\w+\z/
  INVALID_EMAILS = ["joe", "joe@", "gmail.com", "@gmail.com", "@Actually_Twitter", "joe.mama@gmail", "fish@.com", "fish@biz.", "test@com"]
  VALID_EMAILS = ["j@z.com", "jeff.bennett@pittsburghmoves.com", "fish_42@verizon.net", "a.b.c.d@e.f.g.h.biz"]

  DATE_FORMAT = '%b %d, %Y'

  MAILER_FROM_ADDRESS = 'admin@websitefortap.com'
  SMTP_PASSWORD = '%%))$$@tappy'

  YAPA_TYPE_IMAGE_MAP = { :audio => 'yapaaudio.png',
                          :video => 'yapavideo.png',
                          :url => 'yapalink.png',
                          :text => 'yapatext.png',
                          :image => 'yapapicture.png',
                          :coupon => 'yapacoupon.png'}

end
