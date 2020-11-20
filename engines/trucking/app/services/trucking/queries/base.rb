# frozen_string_literal: true

module Trucking
  module Queries
    class Base
      MANDATORY_ARGS = %i[organization_id carriage].freeze

      attr_reader :address, :latitude, :longitude, :zipcode, :city_name, :country_code,
        :organization_id, :load_type, :carriage, :truck_type, :cargo_classes, :nexus_ids,
        :hub_ids, :distance, :groups

      def initialize(args = {})
        argument_errors(args)
        @address = args[:address]
        @latitude = args[:latitude] || args[:address].try(:latitude) || 0
        @longitude = args[:longitude] || args[:address].try(:longitude) || 0
        @zipcode = sanitized_postal_code(args: args)
        @city_name = args[:city_name] || args[:address].try(:city)
        @country_code = args[:country_code] || args[:address].try(:country).try(:code)
        @organization_id = args[:organization_id]
        @load_type = args[:load_type]
        @carriage = args[:carriage]
        @truck_type = args[:truck_type]
        @cargo_classes = args[:cargo_classes]
        @nexus_ids = args[:nexus_ids]
        @hub_ids = args[:hub_ids]
        @groups = args[:groups]
      end

      def locations_locations
        Locations::Location.where(country_code: country_code.downcase).contains(point: point)
      end

      def location_based_locations
        @location_based_locations ||= trucking_locations.where(location: locations_locations)
      end

      def zipcode_based_locations
        @zipcode_based_locations ||= trucking_locations.where(query: :postal_code, data: @zipcode)
      end

      def distance_based_locations
        @distance_based_locations ||= trucking_locations.where(query: :distance)
      end

      def trucking_locations
        @trucking_locations ||= ::Trucking::Location.where(country: country)
      end

      def non_distance_query_types
        @non_distance_query_types ||= type_availabilities
          .where(query_method: %i[location zipcode])
          .select(:query_method)
          .distinct
          .pluck(:query_method)
      end

      def distance_hubs
        @distance_hubs ||= tenant_hubs.where(id: distance_hub_ids)
          .where(
            "ST_DWithin(:point, ST_SetSRID(point, 4326), :radius, true)",
            {point: point.to_s, radius: distance_radius_limit}
          )
      end

      def type_availabilities
        @type_availabilities ||= ::Trucking::TypeAvailability
          .joins(:hub_availabilities)
          .where(
            trucking_hub_availabilities: {
              hub_id: tenant_hubs.select(:id)
            },
            load_type: load_type,
            carriage: carriage
          )
      end

      def distance_hub_ids
        type_availabilities
          .where(query_method: 1)
          .select("trucking_hub_availabilities.hub_id")
          .distinct
      end

      def non_distance_trucking_locations
        return [] if non_distance_query_types.empty?

        base_query_type = non_distance_query_types.first
        base_query = send("#{base_query_type}_based_locations")

        non_distance_query_types.drop(1).inject(base_query) do |query, query_type|
          query.or(send("#{query_type}_based_locations"))
        end
      end

      def distances_with_hubs
        @distances_with_hubs ||= distance_hubs.map { |hub|
          {hub_id: hub.id, distance: calc_distance(hub: hub)}
        }
      end

      def distance_hubs_arguments
        distances_with_hubs.each_with_object([]) { |hub_and_distance, memo|
          distance_location = distance_based_locations.find_by(data: hub_and_distance[:distance].to_i)

          memo << "(#{hub_and_distance[:hub_id]}, '#{distance_location.id}')" if distance_location.present?
        }
      end

      def truckings_for_query
        Rails.cache.fetch(cache_key, expires_in: 12.hours) do
          append_distance_truckings(
            query: validated_truckings.where(location: non_distance_trucking_locations)
          )
        end
      end

      def append_distance_truckings(query:)
        return query if distance_hubs_arguments.empty?

        query.or(
          validated_truckings.where(
            "(hub_id, trucking_truckings.location_id) IN (#{distance_hubs_arguments.join(", ")})"
          )
        )
      end

      def validated_truckings
        @validated_truckings ||= ::Trucking::Trucking.joins(:hub, :location)
          .merge(tenant_hubs)
          .where(organization_id: organization_id)
          .where(cargo_class_condition)
          .where(load_type_condition)
          .where(truck_type_condition)
          .where(carriage_condition)
          .where(group_condition)
      end

      def truck_type_condition
        truck_type.present? ? {truck_type: truck_type} : {}
      end

      def group_condition
        {group_id: groups.pluck(:id)}
      end

      def cargo_class_condition
        cargo_classes.present? ? {cargo_class: cargo_classes} : {}
      end

      def load_type_condition
        load_type.present? ? {load_type: load_type} : {}
      end

      def carriage_condition
        carriage.present? ? {carriage: carriage} : {}
      end

      def hubs_condition
        hub_ids.present? ? {organization_id: organization_id, id: hub_ids} : {organization_id: organization_id}
      end

      def trucking_location_where_statement
        {trucking_locations: {distance: distances}}
      end

      def latitude_longitude
        {latitude: point.y, longitude: point.x}
      end

      def point
        @point ||= RGeo::Cartesian.factory(srid: 4326).point(longitude, latitude)
      end

      def sanitized_postal_code(args:)
        postal_code = args[:zipcode]&.tr(" ", "") || args[:address].try(:get_zip_code)
        country_code = args[:country_code] || args[:address]&.country&.code

        case country_code
        when "NL"
          postal_code[0..-3]
        else
          postal_code
        end
      end

      def tenant_hubs
        @tenant_hubs ||= Legacy::Hub.where(hubs_condition)
      end

      def country
        @country ||= address.present? ? address.country : Legacy::Country.find_by(code: @country_code)
      end

      def cache_key
        [truck_type_condition.values,
          group_condition.values,
          cargo_class_condition.values,
          load_type_condition.values,
          carriage_condition.values,
          hubs_condition.values,
          latitude_longitude.values].flatten.join("-")
      end

      def calc_distance(hub:)
        ::Trucking::GoogleDirections.new(
          address.lat_lng_string,
          hub.lat_lng_string,
          Time.zone.now.to_i
        ).distance_in_km || 0
      end

      def distance_radius_limit
        return 0 if existing_distance_limit.blank?

        (existing_distance_limit.data.to_i * 1000) + 1
      end

      def existing_distance_limit
        @existing_distance_limit ||= trucking_locations.where(query: :distance).order(data: :desc).first
      end
      # Argument Errors

      def argument_errors(args)
        raise_if_no_valid_filter_error(args)
        raise_if_mandatory_arg_error(args)
      end

      def raise_if_mandatory_arg_error(args)
        MANDATORY_ARGS.each do |mandatory_arg|
          raise ArgumentError, "Must provide #{mandatory_arg}" if args[mandatory_arg].nil?
        end
      end

      def raise_if_no_valid_filter_error(args)
        return unless args.keys.size <= MANDATORY_ARGS.length

        raise ArgumentError, "Must provide a valid filter besides #{MANDATORY_ARGS.to_sentence}"
      end
    end
  end
end
