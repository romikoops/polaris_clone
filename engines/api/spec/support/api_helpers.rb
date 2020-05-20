# frozen_string_literal: true

module Requests
  module ApiHelpers
    def response_json
      JSON.parse(response.body)
    end

    def response_data
      response_json.fetch("data")
    end

    def response_meta
      response_json.fetch('meta')
    end

    def response_error
      response_json.fetch("error")
    end
  end
end

RSpec.configure do |config|
  config.include Requests::ApiHelpers, type: :controller
  config.include Requests::ApiHelpers, type: :request
end
