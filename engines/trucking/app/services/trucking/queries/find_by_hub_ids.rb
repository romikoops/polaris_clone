# frozen_string_literal: true

module Trucking
  module Queries
    class FindByHubIds
      attr_reader :filters, :group_id, :hub_ids

      def initialize(args = {})
        argument_errors(args)

        @hub_ids = args[:hub_ids]
        @group_id = args[:group_id]
        @filters = args[:filters] || {}
      end

      def perform
        query = ::Trucking::Trucking.where(hub_id: hub_ids, group_id: group_id).current
        query = query.where(cargo_class: filters[:cargo_class]) if filters[:cargo_class]
        query = query.where(load_type: filters[:load_type]) if filters[:load_type]
        query = query.where(truck_type: filters[:truck_type]) if filters[:truck_type]
        query = query.where(carriage: filters[:carriage]) if filters[:carriage]
        if filters[:destination]
          query = query.joins(:location).where("trucking_locations.data ILIKE ?", "#{filters[:destination]}%")
        end
        if filters[:courier_name]
          query = query.joins(tenant_vehicle: :carrier).where("carriers.name ILIKE ?", "#{filters[:courier_name]}%")
        end

        query
      end

      def argument_errors(args)
        raise ArgumentError, "Must provide hub_ids or hub_id" if args[:hub_ids].empty?
      end
    end
  end
end
