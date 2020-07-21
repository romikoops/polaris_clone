# frozen_string_literal: true

module Api
  module V1
    class TenderDecorator < Draper::Decorator
      delegate_all
      delegate :trip, to: :charge_breakdown
      delegate :vessel, to: :trip

      def route
        itinerary.name
      end

      def charges
        ResultFormatter::FeeTableService.new(tender: object, scope: context[:scope]).perform
      end

      def transit_time
        (trip.end_date.to_date - trip.start_date.to_date).to_i
      end

      def pickup_service
        pickup_tenant_vehicle&.name
      end

      def delivery_service
        delivery_tenant_vehicle&.name
      end

      def pickup_carrier
        pickup_tenant_vehicle&.carrier&.name
      end

      def delivery_carrier
        delivery_tenant_vehicle&.carrier&.name
      end
    end
  end
end
