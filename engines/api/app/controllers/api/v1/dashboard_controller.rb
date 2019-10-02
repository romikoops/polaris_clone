# frozen_string_literal: true

require_dependency 'api/api_controller'

module Api
  module V1
    class DashboardController < ApiController
      def show
        render json: DashboardService.new(user: current_user).data
      end
    end
  end
end
