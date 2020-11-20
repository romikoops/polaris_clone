# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V1
    class UsersController < ApiController
      skip_before_action :ensure_organization!, only: :show

      def show
        if current_user.present?
          render json: UserSerializer.new(UserDecorator.decorate(current_user))
        else
          head :not_found
        end
      end
    end
  end
end
