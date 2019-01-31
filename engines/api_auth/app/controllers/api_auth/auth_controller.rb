# frozen_string_literal: true

require_dependency 'api_auth/application_controller'

module ApiAuth
  class AuthController < ApplicationController
    def destroy
      logout
      doorkeeper_token.revoke

      head :no_content
    end
  end
end
