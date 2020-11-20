# frozen_string_literal: true

PDFKit.configure do |config|
  paths = ["/usr/bin/wkhtmltopdf", "/opt/rubies/ruby-2.5.3/bin/wkhtmltopdf"].freeze
  wkhtmltopdf_path = paths.find { |path| File.exist?(path) }
  config.wkhtmltopdf = wkhtmltopdf_path if wkhtmltopdf_path

  config.default_options = {
    page_size: "A4",
    print_media_type: true,
    dpi: 300,
    zoom: 1
  }
end
