source 'https://rubygems.org'
ruby '3.2.2'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Ruby GraphQL implememntation [https://github.com/rmosolgo/graphql-ruby]
gem 'graphql'

# HTTP is an easy-to-use client library for making requests from Ruby [https://github.com/httprb/http]
gem 'http'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

gem 'mitlibraries-theme', git: 'https://github.com/mitlibraries/mitlibraries-theme', tag: 'v1.4'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1.2'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

gem 'rack-cors'

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :production do
  # Use postgres as the database for Active Record
  gem 'pg'
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows]

  # Allow selective loading of configuration in different contexts (dev/test)
  gem 'dotenv-rails'

  # Use sqlite as the database for Active Record in dev and test
  gem 'sqlite3'
end

group :development do
  # Add annotations to model, test, fixtures when run
  gem 'annotate'

  # RuboCop is a Ruby static code analyzer (a.k.a. linter) and code formatter.
  gem 'rubocop'
  gem 'rubocop-capybara'
  gem 'rubocop-rails'

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"
  gem 'yard'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'simplecov-lcov'
  gem 'vcr'
  gem 'webmock'
end
