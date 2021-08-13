# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class SchedulesController < ApiController
      skip_before_action :doorkeeper_authorize!, only: [:index]

      def index
        render json: Api::V2::ScheduleSerializer.new(
          Api::V2::ScheduleDecorator.decorate_collection(schedules)
        )
      end

      private

      def schedules
        []
      end
    end
  end
end
