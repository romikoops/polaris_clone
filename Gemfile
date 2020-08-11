# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 5.2.2"
# Use sqlite3 as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use postGIS
gem "activerecord-postgis-adapter", "~> 5.2.2"

# Use Puma as the app server
gem "puma", "~> 4.3.5"
# Use activerecord-import for bulk insertion
gem "activerecord-import"
# Strong Migrations - Prevent Non Zero-Down time Migrations
gem "strong_migrations"
# ActiveStorage
gem "activestorage-cascade", "~> 0.1.1"

# i18n support
gem "rails-i18n"

# Easy Monitoring
gem "easymon"

# Skylight APM
gem "skylight"

# Dead Code
gem "coverband"

# Nicer logs
gem "lograge"

gem "devise_token_auth", "~> 0.1.43"
gem "omniauth"
gem "ruby-saml", "~> 1.11.0", require: "onelogin/ruby-saml"

# soft delete users and other models
gem "paranoia", "~> 2.2"

gem "sass-rails"
gem "sprockets-rails", require: "sprockets/railtie"
gem "sprockets", "~> 3.7.2"

# AWS SDK
gem "aws-sdk-s3", "~> 1.77.0"
gem "aws-sdk-sqs", "~> 1.30.0"

gem "font-awesome-rails"

# Background jobs
gem "activejob-traffic_control"
gem "sidekiq", "~> 6.1"
gem "sidekiq-failures"
gem "sidekiq_alive"

# PDF generation
gem "pdfkit"
gem "wkhtmltopdf-binary"

# Used to ensure rgeo is rebuilt on deploy
gem "rgeo", "~> 2.1.1"
gem "rgeo-geojson"

# Full Text Search
gem "pg_search", "~> 2.3.0"
gem "faraday_middleware-aws-sigv4"

# Refactoring critical components
gem "scientist"

gem "dalli"
gem "oj"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem "rack-cors"

# Use geocoder for backend geocoding
gem "geocoder"

# Monitoring
gem "prometheus_exporter", "~> 0.5.2"
gem "sentry-raven"

# Use Nokogiri for XML-parsing
gem "nokogiri"

# Use os to get information about the operating system
gem "os"

# Use roo for handling CSV and Excel files
gem "roo"
gem "roo-xls"
gem "write_xlsx"

# Use chronic for parsing dates
gem "chronic"

# Use table_print for nice SQL output
gem "table_print"

# Filter and sort Active record collections
gem "filterrific"

# Pagination library
gem "will_paginate", "~> 3.3.0"

# Email support
gem "mailgun-ruby", "~> 1.2.0"
gem "premailer-rails"
gem "recipient_interceptor"

# New email gem
gem "mjml-rails", "~> 4.1"

# Image resizing
gem "mini_magick"

# Audit trail for changes
gem "paper_trail", "~> 10.3"

# Google translate api
gem "google-cloud-translate"
gem "googleauth"
gem "signet"

# Better console
gem "pry-rails"

# Add comments to ActiveRecord queries
gem "marginalia", "~> 1.5"

# Determines holidays by region
gem "holidays"

gem "liquid"

# Translated customer content
gem "mobility", "~> 0.8.6"

# Use money gem
gem "money"
gem "money-open-exchange-rates"
gem "money-rails"
gem "money_cache", path: "lib/money_cache"

# Use monetize gem to parse strings into Money objects
gem "monetize"

# Use mimemagic
gem "mimemagic"

# OpenAPI
gem "rswag-api"
gem "rswag-ui"

group :development, :test do
  gem "annotate", "~> 3.0"
  gem "dotenv-rails", require: "dotenv/rails-now"
  gem "factory_bot_rails", "~> 4.0", "< 5"
  gem "fuubar"
  gem "git"
  gem "rails-erd"
  gem "rspec", "~> 3.9"
  gem "rspec-rails"
  gem "rspec_junit_formatter"
  gem "rswag-specs"

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  # Better debugging
  gem "better_errors"
  gem "binding_of_caller"
  gem "debase"
  gem "ruby-debug-ide"

  gem "rubocop-itsmycargo"

  gem "lefthook"
end

group :test do
  gem "rspec-retry"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "simplecov-cobertura", require: false
  gem "timecop"
  gem "webmock"
end

group :development do
  gem "letter_opener", "~> 1.6"

  gem "listen", ">= 3.0.5", "< 3.3"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"

  gem "traceroute"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Engines
Dir["engines/*/*.gemspec"].each do |gemspec_path|
  engine_path = File.dirname(gemspec_path)
  engine_name = File.basename(engine_path)
  gem_name = "imc-#{engine_name}"

  gem gem_name, path: engine_path
end
