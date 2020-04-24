# frozen_string_literal: true

require 'rspec/retry'

RSpec.configure do |config|
  config.around do |ex|
    ex.run_with_retry(retry: 3)
  end
end
