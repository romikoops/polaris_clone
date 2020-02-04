# frozen_string_literal: true

require_dependency 'api/api_controller'

module Api
  module V1
    class UsersController < ApiController
      def show
        render json: current_user, serializer: UserSerializer
      end
    end
  end
end
