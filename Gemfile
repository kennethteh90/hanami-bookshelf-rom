source 'https://rubygems.org'

gem 'byebug'
gem 'hanami', '~> 1.3'
gem 'rake'
# TODO: remove this when hanami-router supports ruby 3
gem 'http_router', github: 'juliogreff/http_router'

gem 'rom', '~> 5.2'
gem 'rom-sql', '~> 3.6'

gem 'pg'
gem 'puma'

group :development do
  # Code reloading
  # See: http://hanamirb.org/guides/projects/code-reloading
  gem 'rubocop'
  gem 'shotgun', platforms: :ruby
end

gem 'dotenv'

group :test do
  gem 'capybara'
  gem 'rspec'
end

group :test, :development do
  gem 'faker'
  gem 'pry-byebug'
end
