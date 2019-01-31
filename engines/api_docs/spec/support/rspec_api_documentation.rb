# frozen_string_literal: true

require 'rspec_api_documentation'
require 'rspec_api_documentation/dsl'

RspecApiDocumentation.configure do |config|
  config.docs_dir = Pathname.new(File.expand_path('../../../../doc/api', __dir__))
  config.format = :append_json
  config.curl_host = ENV.fetch('API_HOST', 'https://api.itsmycargo.com')
  config.api_name = 'ItsMyCargo API'
  config.request_headers_to_include = ['Content-Type']
  config.response_headers_to_include = ['Content-Type', 'WWW-Authenticate']
  config.curl_headers_to_filter = %w(Authorization Cookie)
  config.keep_source_order = true
  config.request_body_formatter = :json
end
