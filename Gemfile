source 'https://rubygems.org'
ruby '2.6.9'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.1'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :production do
  gem 'rails_12factor', '0.0.2'
  gem 'unicorn'
end


group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Use sqlite3 as the database for Active Record
end

gem 'pg'
gem 'taps'
gem 'tilt'

# custom
gem 'high_voltage'
gem 'slim'
gem 'httparty'

gem 'jquery-rails'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'ffaker'
  gem 'shoulda-matchers', '2.8.0'
  gem 'capybara'
  gem 'capybara-console'
  gem 'database_cleaner'
  gem 'capybara-email'
  gem 'poltergeist'
  gem 'phantomjs', :require => 'phantomjs/poltergeist'
end

