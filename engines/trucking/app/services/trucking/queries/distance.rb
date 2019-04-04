# frozen_string_literal: true

module Trucking
  module Queries
    class Distance
      MANDATORY_ARGS = %i(load_type tenant_id carriage).freeze

      def initialize(args = {}) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        argument_errors(args)

        @klass = args[:klass] || ::Trucking::Trucking

        @latitude     = args[:latitude]     || args[:address].try(:latitude)  || 0
        @longitude    = args[:longitude]    || args[:address].try(:longitude) || 0
        @zipcode      = args[:zipcode]      || args[:address].try(:get_zip_code)
        @city_name    = args[:city_name]    || args[:address].try(:city)
        @country_code = args[:country_code] || args[:address].try(:country).try(:code)

        @tenant_id    = args[:tenant_id]
        @load_type    = args[:load_type]
        @carriage     = args[:carriage]
        @truck_type   = args[:truck_type]
        @cargo_classes = args[:cargo_classes]
        @nexus_ids    = args[:nexus_ids]
        @hub_ids      = args[:hub_ids]
        @distance     = args[:distance]
      end

      def perform
        find_relevant_hubs
        find_trucking_locations
      end

      private

      def find_relevant_hubs
        @relevant_hubs = Hub.where(hubs_condition)
                            .joins(trucking_hub_availabilities: :type_availability)
                            .where(trucking_type_availabilities: { query_method: 1 })
                            .uniq
      end

      def find_trucking_locations
        @klass.where(hub_id: @relevant_hubs.pluck(:id, ), carriage: @carriage, tenant_id: @tenant_id,)
              .where(cargo_class_condition)
              .where(truck_type_condition)
              .where(nexuses_condition)
              .joins(%i(location hub))
              .where(trucking_location_where_statement, trucking_location_conditions_binds)
      end

      def trucking_location_where_statement
        if @distance
          { trucking_locations: { distance: @distance } }
        else
          <<-SQL
            trucking_locations.distance = ROUND(ST_Distance(
              ST_Point(hubs.longitude, hubs.latitude)::geography,
              ST_Point(:longitude, :latitude)::geography
            ) / 500)
          SQL
        end
      end

      def trucking_location_conditions_binds
        { latitude: @latitude, longitude: @longitude }
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
        @truck_type ? { 'truck_type': @truck_type } : {}
      end

      def cargo_class_condition
        @cargo_classes ? { 'cargo_class': @cargo_classes } : {}
      end

      def nexuses_condition
        @nexus_ids ? { 'hubs.nexus_id': @nexus_ids } : {}
      end

      def hubs_condition
        @hub_ids ? { 'id': @hub_ids } : {}
      end

      # Argument Errors

      def argument_errors(args)
        raise_if_no_valid_filter_error(args)
        raise_if_mandatory_arg_error(args)
        raise_if_country_code_error(args)
      end

      def raise_if_mandatory_arg_error(args)
        MANDATORY_ARGS.each do |mandatory_arg|
          raise ArgumentError, "Must provide #{mandatory_arg}" if args[mandatory_arg].nil?
        end
      end

      def raise_if_country_code_error(args)
        return unless args[:address].try(:country).try(:code).nil? && args[:country_code].nil?

        raise ArgumentError, 'Must provide country_code'
      end

      def raise_if_no_valid_filter_error(args)
        return unless args.keys.size <= MANDATORY_ARGS.length

        raise ArgumentError, "Must provide a valid filter besides #{MANDATORY_ARGS.to_sentence}"
      end
    end
  end
end
