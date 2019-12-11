# frozen_string_literal: true

PDFKit.configure do |config|
  PATHS = ['/usr/bin/wkhtmltopdf', '/opt/rubies/ruby-2.5.3/bin/wkhtmltopdf'].freeze
  WKHTMLTOPDF_PATH = PATHS.find { |path| File.exist?(path) }
  config.wkhtmltopdf = WKHTMLTOPDF_PATH if WKHTMLTOPDF_PATH

  config.default_options = {
    page_size: 'A4',
    print_media_type: true,
    dpi: 300,
    zoom: 1
  }
end
