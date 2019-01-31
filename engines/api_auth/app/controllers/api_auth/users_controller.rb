# frozen_string_literal: true

require_dependency 'api_auth/api_controller'

module ApiAuth
  class UsersController < ApiController
    def show
      render json: current_user
    end
  end
end
