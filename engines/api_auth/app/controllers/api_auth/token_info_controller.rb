# frozen_string_literal: true

module ApiAuth
  class TokenInfoController < ::Doorkeeper::TokenInfoController
    def show
      if doorkeeper_token&.accessible?
        render json: ::Doorkeeper::OAuth::TokenResponse.new(doorkeeper_token).body, status: :ok
      else
        error = ::Doorkeeper::OAuth::ErrorResponse.new(name: :invalid_request)
        response.headers.merge!(error.headers)
        render json: error.body, status: error.status
      end
    end
  end
end
