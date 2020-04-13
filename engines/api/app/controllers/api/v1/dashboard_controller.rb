# frozen_string_literal: true

require_dependency 'api/api_controller'

module Api
  module V1
    class DashboardController < ApiController
      def show
        render json:
        {
          data: Api::DashboardService.data(
            user: current_user,
            widget_name: widget_param,
            start_date: optional_params[:startDate],
            end_date: optional_params[:endDate]
          )
        }
      end

      def widget_param
        params.require(:widget)
      end

      def optional_params
        params.permit(:startDate, :endDate)
      end
    end
  end
end
