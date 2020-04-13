# frozen_string_literal: true

module Trucking
  module Queries
    class Base
      MANDATORY_ARGS = %i[tenant_id carriage].freeze

      def initialize(args = {}) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        argument_errors(args)

        @klass = args[:klass] || ::Trucking::Trucking
        @address = args[:address]
        @latitude = args[:latitude] || args[:address].try(:latitude) || 0
        @longitude = args[:longitude] || args[:address].try(:longitude) || 0
        @zipcode = sanitized_postal_code(args: args)
        @city_name = args[:city_name] || args[:address].try(:city)
        @country_code = args[:country_code] || args[:address].try(:country).try(:code)

        @tenant_id    = args[:tenant_id]
        @load_type    = args[:load_type]
        @carriage     = args[:carriage]
        @truck_type   = args[:truck_type]
        @cargo_classes = args[:cargo_classes]
        @nexus_ids = args[:nexus_ids]
        @hub_ids = args[:hub_ids]
        @distance = args[:distance]
        @sandbox = args[:sandbox]
        @groups = args[:groups]
      end

      def locations_locations
        Locations::Location.contains(lat: @latitude, lon: @longitude)
      end

      def distance_based_locations
        @distance_based_locations ||= trucking_locations.where(
          trucking_location_where_statement, distances
        )
      end

      def location_based_locations
        @location_based_locations ||= trucking_locations.where(location: locations_locations)
      end

      def zipcode_based_locations
        @zipcode_based_locations ||= trucking_locations.where(zipcode: @zipcode)
      end

      def trucking_locations
        @trucking_locations ||= ::Trucking::Location.where(country_code: @country_code)
      end

      def query_types
        @query_types ||= type_availabilities
                         .where.not(query_method: [nil, 0])
                         .select(:query_method)
                         .distinct
                         .pluck(:query_method)
      end

      def distance_hubs
        @distance_hubs ||= tenant_hubs.where(id: distance_hub_ids)
      end

      def type_availabilities
        @type_availabilities ||= ::Trucking::TypeAvailability
                                 .joins(:hub_availabilities)
                                 .where(
                                   trucking_hub_availabilities: {
                                     hub_id: tenant_hubs.select(:id)
                                   },
                                   load_type: @load_type,
                                   carriage: @carriage
                                 )
      end

      def distance_hub_ids
        type_availabilities
          .where(query_method: 1)
          .select('trucking_hub_availabilities.hub_id')
          .distinct
      end

      def valid_trucking_locations
        return [] if query_types.empty?

        base_query_type = query_types.first
        base_query = send("#{base_query_type}_based_locations")

        query_types.drop(1).inject(base_query) do |query, query_type|
          query.or(send("#{query_type}_based_locations"))
        end
      end

      def distances
        if @distance.present?
          [@distance]
        else
          distance_hubs.map { |hub| hub.distance_to(@address) }
        end
      end

      def truckings_for_query
        ::Trucking::Trucking.joins(:hub)
                            .merge(tenant_hubs)
                            .where(tenant_id: @tenant_id)
                            .where(cargo_class_condition)
                            .where(load_type_condition)
                            .where(truck_type_condition)
                            .where(carriage_condition)
                            .where(group_condition)
                            .where(location: valid_trucking_locations)
      end

      def truck_type_condition
        @truck_type ? { truck_type: @truck_type } : {}
      end

      def group_condition
        @groups ? { group_id: @groups.ids | [nil] } : {}
      end

      def cargo_class_condition
        @cargo_classes ? { cargo_class: @cargo_classes } : {}
      end

      def load_type_condition
        @load_type ? { load_type: @load_type } : {}
      end

      def carriage_condition
        @carriage ? { carriage: @carriage } : {}
      end

      def nexuses_condition
        @nexus_ids ? { 'hubs.nexus_id': @nexus_ids } : {}
      end

      def hubs_condition
        @hub_ids ? { tenant_id: @tenant_id, id: @hub_ids } : { tenant_id: @tenant_id }
      end

      def trucking_location_where_statement
        { trucking_locations: { distance: distances } }
      end

      def trucking_location_conditions_binds
        { latitude: @latitude, longitude: @longitude }
      end

      def sanitized_postal_code(args:)
        postal_code = args[:zipcode]&.tr(' ', '') || args[:address].try(:get_zip_code)
        country_code = args[:country_code] || args[:address]&.country&.code

        case country_code
        when 'NL'
          postal_code[0..-3]
        else
          postal_code
        end
      end

      def tenant_hubs
        @tenant_hubs ||= Legacy::Hub.where(hubs_condition)
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
