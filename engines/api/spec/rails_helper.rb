# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('dummy/config/environment', __dir__)

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'

Dir[File.join(File.expand_path('../../../lib/spec/rails', __dir__), '**', '*.rb')].sort.each { |f| require f }
Dir[File.join(File.expand_path('support', __dir__), '**', '*.rb')].sort.each { |f| require f }
