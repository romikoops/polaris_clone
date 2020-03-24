# frozen_string_literal: true

module Requests
  module ApiHelpers
    def response_json
      JSON.parse(response.body)
    end

    def response_data
      response_json.fetch('data')
    end

    def response_error
      response_json.fetch('error')
    end
  end

  module AcceptanceHelpers
    def response_data
      JSON.parse(response_body).fetch('data')
    end
  end
end

RSpec.configure do |config|
  config.include Requests::ApiHelpers, type: :controller
  config.include Requests::AcceptanceHelpers, acceptance: true
end
