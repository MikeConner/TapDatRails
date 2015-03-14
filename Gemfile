source 'https://rubygems.org'
ruby '2.1.5'

gem 'rails', '4.1.8'
gem 'pg', '0.17.1'
gem 'devise', '3.4.1'
gem 'devise-async', '0.9.0'
gem 'nokogiri', '1.6.1'
gem "font-awesome-rails"
gem 'knockoutjs-rails'

gem 'haml', '4.1.0.beta.1'
gem 'haml-rails', '0.6.0'

# for Admin pages
gem 'rails_admin', '0.6.5'

# gem for api
gem "rocket_pants", "1.10.0"

# 4.1 compatibility
gem 'sass', '~> 3.2.19'
gem 'compass', '~> 0.12.7'
gem 'compass-rails', '~> 2.0.0'
gem 'uglifier', '2.6.0'
gem 'foundation-rails', '5.4.5.0'

gem 'jquery-rails', '3.1.2'
gem 'thin', '1.6.3'

# Move into dev/test when we no longer need fake Bitcoin addresses
gem 'faker', '1.4.3'

# for images on s3
gem 'carrierwave', '0.10.0'
gem "fog", '1.22.1'

#for heroku, have to use this to get to imagemagick
gem 'rmagick', '2.13.4', :require => false
gem 'mini_magick', '4.0.1'
gem 'carrierwave_backgrounder', '0.4.1'
gem 'newrelic_rpm', '3.9.8.273'
gem 'delayed_job_active_record', '4.0.2'
gem 'coinbase', '2.1.1'
gem 'friendly_id', '5.0.4'
gem 'rqrcode-rails3', '0.1.7'
gem 'bcrypt-ruby', '3.0.1'

gem 'mechanize', '2.7.3'

group :development do
  gem 'seed_dump', '3.2.1'
end

group :development, :test do
  gem 'rspec-rails', '3.1.0'
  gem 'annotate', '2.6.5'

end
gem 'better_errors', '2.0.0'
gem 'binding_of_caller', '0.7.2'


group :test do
  gem 'capybara', '2.4.4'
  gem 'database_cleaner', '1.3.0'
  gem 'factory_girl_rails', '4.5.0'
  gem 'rspec-tag_matchers', '0.1.2'
  gem 'rspec-its', '1.1.0'
end

group :production do
  gem 'rails_12factor', '0.0.3'
end
