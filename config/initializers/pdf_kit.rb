# frozen_string_literal: true

PDFKit.configure do |config|
  config.default_options = {
    page_size: 'A4',
    print_media_type: true,
    dpi: 300,
    zoom: 1
  }
  # Use only if your external hostname is unavailable on the server.
  config.verbose = Rails.env.development?
end
