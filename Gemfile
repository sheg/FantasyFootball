source 'https://rubygems.org'

gem 'rails', '4.1.4'

group :development, :test do
  gem 'mysql2'
  gem 'sqlite3', '1.3.8'
  gem 'rspec-rails', '2.13.1'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'faker'
end

group :test do
  gem 'cucumber-rails', '1.4.0', require: false
  gem 'selenium-webdriver', '2.35.1'
  gem 'capybara', '2.1.0'
end

group :assets do
  gem 'sass-rails', '4.0.1'
  gem 'uglifier', '2.1.1'
end

gem 'tzinfo-data'
gem 'jquery-ui-rails'
gem 'jquery-rails'
gem 'bootstrap-timepicker-rails'
gem 'will_paginate', '~> 3.0'
gem 'turbolinks', '1.1.1'
gem 'jbuilder', '1.0.2'
gem 'bcrypt-ruby', '~> 3.1.5', :require => 'bcrypt'
gem 'bootstrap-sass', '2.3.2.0'
gem 'httparty', '0.12.0'
# gem 'composite_primary_keys'
gem 'composite_primary_keys', {
    :git => 'git://github.com/composite-primary-keys/composite_primary_keys.git',
    :branch => 'ar_4.1.x'
}

group :doc do
  gem 'sdoc', '0.3.20', require: false
end

group :production do
  gem 'pg', '0.15.1'
  gem 'rails_12factor', '0.0.2'
end