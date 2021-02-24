# frozen_string_literal: true

source "https://rubygems.org"

gem "activejob-traffic_control"
gem "activerecord-import"
gem "aws-sdk-s3", "~> 1.78.0"
gem "aws-sdk-sqs", "~> 1.30.0"
gem "chronic"
gem "dalli"
gem "easymon"
gem "faraday_middleware-aws-sigv4"
gem "filterrific"
gem "font-awesome-rails"
gem "geocoder"
gem "holidays"
gem "liquid"
gem "lograge"
gem "mailgun-ruby", "~> 1.2.0"
gem "marginalia", "~> 1.5"
gem "mimemagic"
gem "mini_magick"
gem "mjml-rails", "~> 4.1"
gem "mobility", "~> 0.8.6"
gem "monetize"
gem "money"
gem "money-open-exchange-rates"
gem "money-rails"
gem "nokogiri"
gem "oj"
gem "omniauth"
gem "os"
gem "paranoia", "~> 2.2"
gem "pdfkit"
gem "pg_search", "~> 2.3.0"
gem "premailer-rails"
gem "prometheus_exporter", "~> 0.5.2"
gem "pry-rails"
gem "puma", "< 6"
gem "rack-cors"
gem "rails-i18n"
gem "recipient_interceptor"
gem "rgeo", "~> 2.1.1"
gem "rgeo-geojson"
gem "roo"
gem "roo-xls"
gem "rswag-api"
gem "rswag-ui"
gem "ruby-saml", "~> 1.11.0", require: "onelogin/ruby-saml"
gem "sass-rails"
gem "scientist"
gem "sentry-rails"
gem "sentry-ruby"
gem "sentry-sidekiq"
gem "sidekiq-cron", "~> 1.1"
gem "sidekiq-failures"
gem "sidekiq_alive"
gem "sprockets", "~> 3.7.2"
gem "sprockets-rails", require: "sprockets/railtie"
gem "table_print"
gem "will_paginate", "~> 3.3.0"
gem "wkhtmltopdf-binary"
gem "write_xlsx"

group :development do
  gem "annotate", "~> 3.0"
  gem "better_errors"
  gem "binding_of_caller"
  gem "git"
  gem "lefthook"
  gem "letter_opener", "~> 1.6"
  gem "listen", ">= 3.0.5", "< 3.3"
  gem "rails-erd"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "traceroute"

  # Guard
  gem "guard", "~> 2.16"
  gem "guard-bundler", require: false
  gem "guard-rspec", require: false

  # Rubocop
  gem "rubocop"
  gem "rubocop-github", "0.16.0"
  gem "rubocop-performance", "~>1.7.1"
  gem "rubocop-rails", "~> 2.5"
  gem "rubocop-rspec", "~> 1.41.0"
end

group :development, :test do
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "debase"
  gem "rspec", "~> 3.10"
  gem "rspec-rails"
  gem "rswag-specs"
  gem "ruby-debug-ide"
  gem "shared-factory", path: "gems/shared-factory"
end

group :test do
  gem "fuubar"
  gem "rspec-instafail"
  gem "rspec-retry"
  gem "rspec_count_formatter"
  gem "rspec_junit_formatter"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "simplecov-cobertura", require: false
  gem "timecop"
  gem "webmock"
end

# Engines
group :default, :engines do
  Dir["engines/*"].each do |engine|
    gem File.basename(engine), path: engine
  end
end

gem "measured-itsmycargo", path: "gems/measured-itsmycargo"
gem "money_cache", path: "gems/money_cache"
gem "shared-runtime", path: "gems/shared-runtime"
