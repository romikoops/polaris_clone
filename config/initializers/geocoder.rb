# frozen_string_literal: true

Geocoder.configure(
  lookup: :google,
  
  # Use API key (server key from Google)
  api_key: Settings.google.api_key,
  use_https:  false,
  # Set default units to kilometers:
  units: :km,

  # Geocoding service request timeout, in seconds (default 3):
  timeout: 2000
)
