source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

gem "rails", "~> 7.0.3"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "jbuilder"
gem "redis", "~> 4.0"
gem "bootsnap", require: false
gem "rack-cors"

group :development, :test do
  gem 'database_cleaner-active_record'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rubycritic', require: false
end

group :development do
  gem 'brakeman'
  gem 'bundle-audit'
  gem 'listen'
  gem 'lefthook'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :test do
  gem 'shoulda-matchers', '~> 5.0'
  gem 'simplecov', require: false
end


