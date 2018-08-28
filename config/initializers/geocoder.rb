# frozen_string_literal: true

Geocoder.configure(
  # Use API key (server key from Google)
  api_key: ENV['GOOGLE_MAPS_SERVER_API_KEY'],
  use_https:  false,
  # Set default units to kilometers:
  units: :km,

  # Geocoding service request timeout, in seconds (default 3):
  timeout: 2000
)
