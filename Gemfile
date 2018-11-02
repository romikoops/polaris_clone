# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.1'
# Use sqlite3 as the database for Active Record
gem 'pg', '~> 0.21'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use activerecord-import for bulk insertion
gem 'activerecord-import'
# Strong Migrations - Prevent Non Zero-Down time Migrations
gem 'strong_migrations'

# Easy Monitoring
gem 'easymon'

# Nicer logs
gem 'lograge'

# Setup RailsConfig for easier secret management
gem 'config'

gem 'devise_token_auth', '~> 0.1.43'
gem 'omniauth'

gem 'sass-rails'
gem 'sprockets-rails', require: 'sprockets/railtie'

gem 'awesome_print'
gem 'aws-sdk-sqs', '~> 1.9.0'
gem 'bootstrap-sass', '~> 3.3.5.1'
gem 'font-awesome-rails'
gem 'rufo'
gem 'shoryuken'

gem 'activerecord-postgis-adapter'
gem 'rgeo-geojson'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

# Use geocoder for backend geocoding
gem 'geocoder'

# gem 'remote_syslog_logger'
gem 'sentry-raven'

# Use Nokogiri for XML-parsing
gem 'nokogiri'

# Use os to get information about the operating system
gem 'os'

# Use BreezyPdf to generate PDFs from HTML
gem 'breezy_pdf_lite'

# MongoDB gems
gem 'mongo', '~> 2.4'
# gem 'nio4r', '~> 2.2.0'

# Use roo for handling CSV and Excel files
gem 'roo'
# gem 'roo-xls'
gem 'write_xlsx'

# Usee http for simple requests
gem 'http'

# Use chronic for parsing dates
gem 'chronic'

# Use table_print for nice SQL output
gem 'table_print'

# Filter and sort Active record collections
gem 'filterrific'

# Pagination library
gem 'will_paginate', '~> 3.1.5'

# Email support
gem 'recipient_interceptor'

# Easier CSS for emails
gem 'inky-rb', require: 'inky'
gem 'premailer-rails'

# Image resizing
gem 'mini_magick'

# Audit trail for changes
gem 'paper_trail'

# AWS SDK for hosting and S3
gem 'aws-sdk', '~> 3'

# Google translate api
gem 'google-cloud-translate'
gem 'googleauth'
gem 'signet'
# New email gem
gem 'mjml-rails', '~> 4.1'

# Better console
gem 'pry-rails'

# Add comments to ActiveRecord queries
gem 'marginalia', '~> 1.5'

group :development, :test do
  # set environment variables - enforce loading environment right away
  gem 'dotenv-rails', require: 'dotenv/rails-now'
  gem 'factory_bot_rails'
  gem 'fuubar'
  gem 'rails-erd'
  gem 'rspec-rails'
  gem 'rspec_junit_formatter'
  gem 'rubocop'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i(mri mingw x64_mingw)
  # Better debugging
  gem 'debase'
  gem 'ruby-debug-ide'
end

group :test do
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'vcr', '~>2.8.0'
  gem 'webmock'
end

group :development do
  gem 'google-api-client', '~> 0.23.7'
  gem 'google-cloud-storage'
  gem 'letter_opener', '~> 1.6'

  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i(mingw mswin x64_mingw jruby)
