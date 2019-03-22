# frozen_string_literal: true

module Trucking
  module Queries
    class FindByHubIds
      attr_reader :result

      def initialize(args = {})
        argument_errors(args)

        @klass = args[:klass]
        @hub_ids = args[:hub_ids]
        @filters = args[:filters] || {}
      end

      def perform
        query = @klass.where(hub_id: @hub_ids)
        query = query.where(cargo_class: @filters[:cargo_class]) if @filters[:cargo_class]
        query = query.where(load_type: @filters[:load_type]) if @filters[:load_type]
        query = query.where(truck_type: @filters[:truck_type]) if @filters[:truck_type]
        query = query.where(carriage: @filters[:carriage]) if @filters[:carriage]
        if @filters[:destination]
          query = query.joins(:location).where('trucking_locations.city_name ILIKE ?', "#{@filters[:destination]}%")
        end
        @result = query
      end

      def argument_errors(args)
        raise ArgumentError, 'Must provide hub_ids or hub_id' if args[:hub_ids].empty?
      end
    end
  end
end
