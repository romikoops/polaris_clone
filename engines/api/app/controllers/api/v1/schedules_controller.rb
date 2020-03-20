# frozen_string_literal: true

module Api
  module V1
    class SchedulesController < ApiController
      def show
        decorated_trips = Api::V1::TripDecorator.decorate_collection(
          trips, context: { tender_id: schedule_params[:id] }
        )
        render json: TripSerializer.new(decorated_trips, params: {})
      end

      private

      def schedule_params
        params.permit(:id)
      end

      def tender
        Quotations::Tender.find_by(id: schedule_params[:id])
      end

      def trips
        tender.itinerary.trips.where(
          tenant_vehicle_id: tender.tenant_vehicle_id, load_type: tender.load_type
        ).lastday_today.limit(50)
      end
    end
  end
end
