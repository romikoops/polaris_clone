# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class SchedulesController < ApiController
      def index
        render json: Api::V2::ScheduleSerializer.new(
          Api::V2::ScheduleDecorator.decorate_collection(filtered_schedules)
        )
      end

      def show
        render json: Api::V2::ScheduleSerializer.new(
          Api::V2::ScheduleDecorator.decorate(schedule)
        )
      end

      private

      def filtered_schedules
        @filtered_schedules ||= Schedules::Schedule.where(
          organization_id: current_organization.id,
          origin: decorated_result.origin_route_point.locode,
          destination: decorated_result.destination_route_point.locode,
          closing_date: Time.zone.now..Float::INFINITY,
          carrier: decorated_result.carrier,
          service: decorated_result.service_level,
          mode_of_transport: decorated_result.main_freight_section.mode_of_transport
        )
      end

      def decorated_result
        @decorated_result ||= Api::V2::ResultDecorator.new(Journey::Result.find(params[:result_id]))
      end

      def schedule
        @schedule ||= Schedules::Schedule.find(params[:id])
      end
    end
  end
end
