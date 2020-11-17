# frozen_string_literal: true

require 'spec_helper'
require "factory_bot_rails"

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

Dir[File.join(File.expand_path('support', __dir__), 'rails', '**', '*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.filter_rails_from_backtrace!
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
end

# Shared context
Dir[File.join(File.expand_path(__dir__), '**', 'shared', '*.rb')].sort.each { |f| require f }
