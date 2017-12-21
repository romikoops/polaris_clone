Geocoder.configure(
  # Use API key (server key from Google)
  :api_key => Rails.application.secrets.google_maps_server_api_key,

  # Set default units to kilometers:
  :units => :km,

   # Geocoding service request timeout, in seconds (default 3):
  :timeout => 1200,
)