# frozen_string_literal: true

module Trucking
  module Queries
    class Availability < ::Trucking::Queries::Base
      def perform
        ::Trucking::Trucking
          .where(
            tenant_id: @tenant_id,
            location_id: trucking_locations.pluck(:id),
            carriage: @carriage,
            sandbox_id: @sandbox&.id
          )
          .where(load_type_condition)
          .where(cargo_class_condition)
          .where(hubs_condition)
          .where(truck_type_condition)
          .where(nexuses_condition)
          .order("#{@order_by} DESC NULLS LAST")
      end
    end
  end
end
