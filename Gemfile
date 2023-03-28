# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.1'
gem 'rails', '~> 7.0.3'

gem 'activerecord-import'
gem 'active_storage_base64'
gem 'bootsnap', require: false
gem 'devise'
gem 'devise-jwt'
gem 'enumerize'
gem 'jbuilder'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'pundit', '~> 2.2'
gem 'sentry-ruby'
gem 'sentry-rails'
gem 'sentry-sidekiq'
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'store_model'
gem 'rack-cors'
gem 'redis', '~> 4.0'
gem 'rswag-api'
gem 'rswag-ui'

group :development, :test do
  gem 'database_cleaner-active_record'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rubycritic', require: false
end

group :development do
  gem 'brakeman'
  gem 'bundle-audit'
  gem 'lefthook'
  gem 'letter_opener'
  gem 'listen'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :test do
  gem 'rswag-specs'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'simplecov', require: false
end
