# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    Geocoder.configure(lookup: :test, ip_lookup: :test) if defined? Geocoder
  end
end
