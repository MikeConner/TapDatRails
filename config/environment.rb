# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = { 
  :address => 'smtp.gmail.com', 
  :domain  => 'machovy.com',
  :port      => 587, 
  :user_name => 'machovy@machovy.com',
  :password => ApplicationHelper::SMTP_PASSWORD, 
  :authentication => :plain,
  :enable_starttls_auto => true
} 
