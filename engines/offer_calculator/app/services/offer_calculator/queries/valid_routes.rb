# frozen_string_literal: true

module OfferCalculator
  module Queries
    class ValidRoutes
      def initialize(args = {})
        args = args.with_indifferent_access
        @itinerary_ids = args.dig(:query, :itinerary_ids)
        @origin_hub_ids = args.dig(:query, :origin_hub_ids)
        @destination_hub_ids = args.dig(:query, :destination_hub_ids)
        @request = args[:request]
        @scope = args[:scope]
        @cargo_classes = @request.cargo_classes
        @user = @request.client
        @date_range = args[:date_range] || (Time.zone.today..1.month.from_now)
        @user_groups = OrganizationManager::GroupsService.new(
          organization: @request.organization,
          target: @user,
          exclude_default: @scope[:dedicated_pricings_only]
        ).fetch
      end

      def perform
        sanitized_query = ActiveRecord::Base.sanitize_sql_array([raw_query, binds])
        ActiveRecord::Base.connection.exec_query(sanitized_query).to_a
      end

      private

      def binds
        {
          organization_id: @request.organization.id,
          origin_hub_ids: @origin_hub_ids,
          destination_hub_ids: @destination_hub_ids,
          cargo_classes: @cargo_classes,
          group_ids: @user_groups.pluck(:id),
          load_type: @request.load_type
        }.merge(date_range_values)
      end

      def date_range_values
        {
          start: @date_range.first,
          end: @date_range.last,
          vatoa: @date_range.last + 1.month
        }
      end

      def raw_query
        <<-SQL
          SELECT DISTINCT
            itineraries.id                             AS itinerary_id,
            itineraries.mode_of_transport              AS mode_of_transport,
            itineraries.origin_hub_id                 AS origin_hub_id,
            itineraries.destination_hub_id            AS destination_hub_id,
            tenant_vehicles.id                         AS tenant_vehicle_id,
            tenant_vehicles.carrier_id                 AS carrier_id
          FROM itineraries
          JOIN pricings_pricings
            ON itineraries.id = pricings_pricings.itinerary_id
          JOIN tenant_vehicles AS tenant_vehicles
            ON tenant_vehicles.id = pricings_pricings.tenant_vehicle_id
          JOIN groups_groups
            ON groups_groups.id = pricings_pricings.group_id
          #{origin_local_charges}
          #{destination_local_charges}
          #{trip_restriction}
          WHERE itineraries.organization_id  = :organization_id
          AND pricings_pricings.group_id IN (:group_ids)
          AND pricings_pricings.cargo_class IN (:cargo_classes)
          AND itineraries.origin_hub_id IN (:origin_hub_ids)
          AND itineraries.destination_hub_id IN (:destination_hub_ids)
          AND pricings_pricings.internal = false
          AND pricings_pricings.validity && daterange(:start::date, :end::date)
        SQL
      end

      def trip_restriction
        return if quotation_tool

        "JOIN trips AS trips
          ON trips.itinerary_id = itineraries.id
          AND trips.tenant_vehicle_id = pricings_pricings.tenant_vehicle_id
          AND trips.load_type = :load_type
          AND trips.start_date > :start"
      end

      def origin_local_charges
        return unless @request.pre_carriage? && local_charges_required_with_trucking?

        "JOIN local_charges AS origin_local_charges
          ON origin_local_charges.hub_id = itineraries.origin_hub_id
          AND origin_local_charges.mode_of_transport = itineraries.mode_of_transport
          AND origin_local_charges.direction = 'export'
          AND origin_local_charges.load_type in (:cargo_classes)
          AND origin_local_charges.tenant_vehicle_id = tenant_vehicles.id
          AND origin_local_charges.validity && daterange(:start::date, :end::date)"
      end

      def destination_local_charges
        return unless @request.on_carriage? && local_charges_required_with_trucking?

        "JOIN local_charges AS destination_local_charges
          ON destination_local_charges.hub_id = itineraries.destination_hub_id
          AND destination_local_charges.mode_of_transport = itineraries.mode_of_transport
          AND destination_local_charges.direction = 'import'
          AND destination_local_charges.load_type in (:cargo_classes)
          AND destination_local_charges.tenant_vehicle_id = tenant_vehicles.id
          AND destination_local_charges.validity && daterange(:start::date, :vatoa::date)"
      end

      def quotation_tool
        @scope[:closed_quotation_tool] || @scope[:open_quotation_tool]
      end

      def local_charges_required_with_trucking?
        @scope[:local_charges_required_with_trucking]
      end
    end
  end
end
