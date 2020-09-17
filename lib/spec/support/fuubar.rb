# frozen_string_literal: true

unless ENV["CI"]
  RSpec.configure do |config|
    config.add_formatter "Fuubar"
  end
end
