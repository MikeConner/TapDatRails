source 'https://rubygems.org'
ruby '2.1.4'

gem 'rails', '3.2.20'
gem 'pg', '0.17.1'
gem 'devise', '2.2.8'
gem 'devise-async', '0.7.0'
gem 'nokogiri', '1.6.1'

gem 'haml', '4.0.5'
gem 'haml-rails', '0.4'

# for Admin pages
gem 'rails_admin', '0.4.9'

# gem for api
gem "rocket_pants", "1.10.0"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '3.2.6'
  gem 'coffee-rails', '3.2.2'
  gem 'uglifier', '2.5.3'
  gem 'foundation-rails', '5.4.5.0'
end

gem 'jquery-rails', '3.1.2'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

gem 'thin', '1.6.2'

# Move into dev/test when we no longer need fake Bitcoin addresses
gem 'faker', '1.4.2'

# for images on s3
gem 'carrierwave', '0.10.0'
gem 'fog', '1.22.0'
#for heroku, have to use this to get to imagemagick
gem 'rmagick', '2.13.1', :require => false
gem 'mini_magick', '4.0.0'
gem 'carrierwave_backgrounder', '0.4.1'
gem 'newrelic_rpm', '3.9.6.257'
gem 'delayed_job_active_record', '0.3.3'
gem 'coinbase', '1.3.0'
gem 'friendly_id', '4.0.9'
gem 'rqrcode-rails3', '0.1.7'

group :development, :test do
  gem 'rspec-rails', '2.13.2'
  gem 'annotate', '2.6.1'
  gem 'better_errors', '1.1.0'
  gem 'binding_of_caller', '0.7.2'
end

group :test do
  gem 'capybara', '2.4.4'
  gem 'database_cleaner', '1.3.0'
  gem 'factory_girl_rails', '4.5.0'
  gem 'rspec-tag_matchers', '0.1.2'
end

group :production do
  gem 'rails_12factor', '0.0.3'
end
