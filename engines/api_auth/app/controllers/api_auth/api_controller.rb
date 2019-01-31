# frozen_string_literal: true

require_dependency 'api_auth/application_controller'

module ApiAuth
  class ApiController < ApplicationController
    before_action :doorkeeper_authorize!
    helper_method :current_user

    private

    def current_user
      @current_user ||= ::Tenants::User.find_by(id: doorkeeper_token.resource_owner_id) if doorkeeper_token
    end
  end
end
