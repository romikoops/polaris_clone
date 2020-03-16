# frozen_string_literal: true

require_dependency 'api/api_controller'

module Api
  module V1
    class UsersController < ApiController
      def show
        decorated_user = UserDecorator.decorate(current_user)
        render json: UserSerializer.new(decorated_user)
      end
    end
  end
end
