# frozen_string_literal: true
module Queries
  module TruckingPricing
    class FindByFilter
      MANDATORY_ARGS = %i(load_type tenant_id carriage).freeze

      def initialize(args={})
        argument_errors(args)

        @klass = args[:klass]

        @latitude     = args[:latitude]     || args[:location].try(:latitude)  || 0
        @longitude    = args[:longitude]    || args[:location].try(:longitude) || 0
        @zipcode      = args[:zipcode]      || args[:location].try(:get_zip_code)
        @city_name    = args[:city_name]    || args[:location].try(:city)
        @country_code = args[:country_code] || args[:location].try(:country).try(:code)

        @tenant_id   = args[:tenant_id]
        @load_type   = args[:load_type]
        @carriage    = args[:carriage]
        @truck_type  = args[:truck_type]
        @cargo_class = args[:cargo_class]
        @nexus_ids   = args[:nexus_ids]
        @hub_ids     = args[:hub_ids]
        @distance    = args[:distance]
      end

      def perform
        @klass
          .joins(:trucking_pricing_scope, hub_truckings: %i(trucking_destination hub))
          .where(
            'hubs.tenant_id':                     @tenant_id,
            'trucking_pricing_scopes.load_type':  @load_type,
            'trucking_pricing_scopes.carriage':   @carriage,
            'trucking_destinations.country_code': @country_code
          )
          .where(cargo_class_condition)
          .where(truck_type_condition)
          .where(nexuses_condition)
          .where(hubs_condition)
          .where(trucking_destination_where_statement, trucking_destination_conditions_binds)
          .select("hubs.id AS preloaded_hub_id, trucking_pricings.*")
      end

      private

      def trucking_destination_where_statement
        <<-SQL
          (
            (trucking_destinations.zipcode IS NOT NULL)
            AND (trucking_destinations.zipcode = :zipcode)
          ) OR (
            (trucking_destinations.geometry_id IS NOT NULL)
            AND (
              SELECT ST_Contains(
                (
                  SELECT data::geometry FROM geometries
                  WHERE id = trucking_destinations.geometry_id
                ),
                (SELECT ST_Point(:longitude, :latitude)::geometry)
              ) AS contains
            )
          ) OR (
            (trucking_destinations.distance IS NOT NULL)
            AND (
              trucking_destinations.distance = #{distance_to_match}
            )
          )
        SQL
      end

      def trucking_destination_conditions_binds
        { zipcode: @zipcode, city_name: @city_name, latitude: @latitude, longitude: @longitude }
      end

      def distance_to_match
        @klass.public_sanitize_sql(
          @distance || <<-SQL
            (
              SELECT ROUND(ST_Distance(
                ST_Point(hubs.longitude, hubs.latitude)::geography,
                ST_Point(:longitude, :latitude)::geography
              ) / 500)
            )
          SQL
        )
      end

      def truck_type_condition
        @truck_type ? { 'trucking_pricing_scopes.truck_type': @truck_type } : {}
      end

      def cargo_class_condition
        @cargo_class ? { 'trucking_pricing_scopes.cargo_class': @cargo_class } : {}
      end

      def nexuses_condition
        @nexus_ids ? { 'hubs.nexus_id': @nexus_ids } : {}
      end

      def hubs_condition
        @hub_ids ? { 'hubs.id': @hub_ids } : {}
      end

      # Argument Errors

      def argument_errors(args)
        raise_if_mandatory_arg_error(args)
        raise_if_country_code_error(args)
        raise_if_no_valid_filter_error(args)
      end

      def raise_if_mandatory_arg_error(args)
        MANDATORY_ARGS.each do |mandatory_arg|
          raise ArgumentError, "Must provide #{mandatory_arg}" if args[mandatory_arg].nil?
        end
      end

      def raise_if_country_code_error(args)
        return unless args[:location].try(:country).try(:code).nil? && args[:country_code].nil?

        raise ArgumentError, "Must provide country_code"
      end

      def raise_if_no_valid_filter_error(args)
        return unless args.keys.size <= MANDATORY_ARGS.length

        raise ArgumentError, "Must provide a valid filter besides #{MANDATORY_ARGS.to_sentence}"
      end
    end
  end
end
