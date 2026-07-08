source "https://rubygems.org"

ruby "3.4.4"

gem "rails", "~> 8.1.3"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "faraday", "~> 2.0"
gem "solid_queue", "~> 1.4"
gem "bootsnap", require: false

gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "dotenv-rails", require: false
  gem "rspec-rails", "~> 8.0"
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "brakeman", require: false
end

group :test do
  gem "simplecov", require: false
  gem "factory_bot_rails"
end
