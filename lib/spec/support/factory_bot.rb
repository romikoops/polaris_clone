# frozen_string_literal: true

require 'factory_bot_rails'

FactoryBot::SyntaxRunner.class_eval do
  include RSpec::Mocks::ExampleMethods
end
