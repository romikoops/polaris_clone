# frozen_string_literal: true

module ExcelDataServices
  module Row
    class Pricing < Base
      def itinerary
        @itinerary ||= Itinerary.find_by(name: itinerary_name, tenant: tenant)
      end

      def itinerary_name
        @itinerary_name ||= [data[:origin], data[:destination]].join(' - ')
      end

      def tenant_vehicle
        @tenant_vehicle ||= TenantVehicle.find_by(
          tenant: tenant,
          name: data[:service_level],
          carrier: carrier,
          mode_of_transport: data[:mot]
        )
      end
    end
  end
end
