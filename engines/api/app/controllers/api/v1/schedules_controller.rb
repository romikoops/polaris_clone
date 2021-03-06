# frozen_string_literal: true

module Api
  module V1
    class SchedulesController < ApiController
      include UsersUserAccess
      def show
        decorated_trips = Api::V1::TripDecorator.decorate_collection(
          trips, context: { tender_id: schedule_params[:id] }
        )
        render json: TripSerializer.new(decorated_trips, params: {})
      end

      def enabled
        scope = OrganizationManager::ScopeService.new(organization: current_organization).fetch
        schedules_enabled = !(scope["closed_quotation_tool"] || scope["open_quotation_tool"])
        render json: { data: { enabled: schedules_enabled } }
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
