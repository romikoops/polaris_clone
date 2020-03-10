# frozen_string_literal: true

module Trucking
  module Queries
    class Distance < ::Trucking::Queries::Base
      def perform
        find_trucking_truckings
      end

      private

      def hubs_condition
        condition = { tenant_id: @tenant_id }
        @hub_ids ? condition.merge(id: @hub_ids) : {}
      end

      def find_trucking_truckings
        @klass.where(
          hub_id: distance_hubs.pluck(:id),
          carriage: @carriage,
          tenant_id: @tenant_id,
          sandbox_id: @sandbox&.id
        )
              .where(cargo_class_condition)
              .where(truck_type_condition)
              .where(nexuses_condition)
              .joins(%i[location hub])
              .where(trucking_location_where_statement, trucking_location_conditions_binds)
              .order("#{@order_by} DESC NULLS LAST")
      end
    end
  end
end
