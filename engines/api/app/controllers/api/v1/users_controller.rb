# frozen_string_literal: true

require_dependency 'api/api_controller'

module Api
  module V1
    class UsersController < ApiController
      skip_before_action :ensure_organization!, only: :show

      def show
        render json: UserSerializer.new(UserDecorator.decorate(current_user))
      end
    end
  end
end
