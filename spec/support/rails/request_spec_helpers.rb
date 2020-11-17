# frozen_string_literal: true

module RequestSpecHelpers
  module FormatHelpers
    def json
      JSON.parse(response.body).deep_symbolize_keys
    end
  end

  module TokenHelper
    def append_token_header
      access_token = Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public")
      token_header = "Bearer #{access_token.token}"
      request.headers["Authorization"] = token_header
    end
  end
end

RSpec.configure do |config|
  config.include RequestSpecHelpers::FormatHelpers, type: :request
  config.include RequestSpecHelpers::FormatHelpers, type: :controller
  config.include RequestSpecHelpers::TokenHelper, type: :controller
  config.include Rails.application.routes.url_helpers
end
