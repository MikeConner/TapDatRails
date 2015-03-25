# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  :address => 'smtp.gmail.com',
  :domain  => 'tapdatapp.co',
  :port      => 587,
  :user_name => 'admin@tapdatapp.co',
  :password => ApplicationHelper::SMTP_PASSWORD,
  :authentication => :plain,
  :enable_starttls_auto => true
}
