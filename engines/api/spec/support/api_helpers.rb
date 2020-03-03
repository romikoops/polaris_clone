# frozen_string_literal: true

module Requests
  module ApiHelpers
    def response_json
      JSON.parse(response.body)
    end

    def response_data
      response_json.fetch('data')
    end
  end
end

RSpec.configure do |config|
  config.include Requests::ApiHelpers, type: :controller
end
