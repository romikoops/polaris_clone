# frozen_string_literal: true

module Wheelhouse
  class EquipmentService
    def initialize(user:, organization:, origin: nil, destination: nil, dedicated_pricings_only: false)
      @user = user
      @organization = organization
      @origin_nexus_ids = nexus_ids(target: 'origin', location: origin)
      @destination_nexus_ids = nexus_ids(target: 'destination', location: destination)
      @group_ids = user_groups
      @dedicated_pricings_only = dedicated_pricings_only
    end

    def perform
      sanitized_query = ActiveRecord::Base.sanitize_sql_array([base_query, binds])
      ActiveRecord::Base.connection.exec_query(sanitized_query).rows.flatten
    end

    private

    attr_reader :organization, :user, :origin_nexus_ids, :destination_nexus_ids, :group_ids, :dedicated_pricings_only

    def binds
      {
        organization_id: organization.id,
        origin_nexus_ids: origin_nexus_ids,
        destination_nexus_ids: destination_nexus_ids,
        group_ids: group_ids
      }
    end

    def base_query
      <<-SQL
        SELECT DISTINCT
          pricings_pricings.cargo_class
        FROM pricings_pricings
        #{origin_condition}
        #{destination_condition}
        JOIN itineraries
          ON itineraries.organization_id = :organization_id
        #{itinerary_condition}
        WHERE pricings_pricings.itinerary_id = itineraries.id
        AND pricings_pricings.load_type = 'container'
        #{group_condition}
      SQL
    end

    def group_condition
      return if dedicated_pricings_only.blank?

      'AND pricings_pricings.group_id IN (:group_ids)'
    end

    def origin_condition
      return if origin_nexus_ids.empty?

      <<-SQL
       JOIN hubs as origin_hubs
         ON origin_hubs.nexus_id IN (:origin_nexus_ids)
         AND origin_hubs.organization_id = :organization_id
       JOIN stops AS origin_stops
         ON origin_stops.hub_id = origin_hubs.id
      SQL
    end

    def destination_condition
      return if destination_nexus_ids.empty?

      <<-SQL
        JOIN hubs as destination_hubs
          ON destination_hubs.nexus_id IN (:destination_nexus_ids)
          AND destination_hubs.organization_id = :organization_id
        JOIN stops AS destination_stops
          ON destination_stops.hub_id = destination_hubs.id
      SQL
    end

    def itinerary_condition
      return unless origin_nexus_ids.present? || destination_nexus_ids.present?

      condition = ''
      condition += 'AND itineraries.id = origin_stops.itinerary_id' if origin_nexus_ids.present?
      condition += ' AND itineraries.id = destination_stops.itinerary_id' if destination_nexus_ids.present?
      condition
    end

    def nexus_ids(location:, target:)
      return [] if location.nil?
      return [location[:nexus_id]] if location[:nexus_id].present?

      ::Trucking::Queries::Hubs.new(
        organization_id: organization.id,
        address: address(latitude: location[:latitude], longitude: location[:longitude]),
        carriage: target == 'origin' ? 'pre' : 'on',
        order_by: 'group_id',
        load_type: 'container'
      ).perform.select(:nexus_id).distinct.pluck(:nexus_id)
    end

    def address(latitude:, longitude:)
      address = Geocoder.search([latitude.to_f, longitude.to_f]).first
      return unless address

      OpenStruct.new(
        latitude: latitude.to_f,
        longitude: longitude.to_f,
        get_zip_code: address.postal_code,
        city_name: address.city,
        country: OpenStruct.new(code: address.country_code)
      )
    end

    def user_groups
      return [] if user.blank?

      company_ids = Companies::Membership.where(member: user).select(:company_id)
      query = Groups::Group.joins(:memberships)
      query.where(groups_memberships: {member_type: 'Users::User', member_id: user.id}).or(
        query.where(groups_memberships: {member_type: 'Companies::Companies', member_id: company_ids})
      ).ids
    end
  end
end
