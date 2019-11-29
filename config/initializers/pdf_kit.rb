# frozen_string_literal: true

PDFKit.configure do |config|
  config.wkhtmltopdf = if Rails.env.production?
    '/opt/rubies/ruby-2.5.3/bin/wkhtmltopdf'
  else
    '/usr/bin/wkhtmltopdf'
  end

  config.default_options = {
    page_size: 'A4',
    print_media_type: true,
    dpi: 300,
    zoom: 1
  }
  # Use only if your external hostname is unavailable on the server.
  config.verbose = Rails.env.development?
end
