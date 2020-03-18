# frozen_string_literal: true

module Api
  class EquipmentService
    def initialize(user:, origin_nexus_id: nil, destination_nexus_id: nil, dedicated_pricings_only: false)
      @user = user
      @tenant_id = user.tenant.legacy_id
      @origin_nexus_id = origin_nexus_id&.to_i
      @destination_nexus_id = destination_nexus_id&.to_i
      @group_ids = @user.all_groups.ids
      @dedicated_pricings_only = dedicated_pricings_only
    end

    def perform
      sanitized_query = ActiveRecord::Base.sanitize_sql_array([base_query, binds])
      ActiveRecord::Base.connection.exec_query(sanitized_query).to_a.pluck('cargo_class')
    end

    private

    def binds
      {
        tenant_id: @tenant_id,
        origin_nexus_id: @origin_nexus_id,
        destination_nexus_id: @destination_nexus_id,
        group_ids: @group_ids
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
          ON itineraries.tenant_id = :tenant_id
        #{itinerary_condition}
        WHERE pricings_pricings.itinerary_id = itineraries.id
        AND pricings_pricings.load_type = 'container'
        #{group_condition}
      SQL
    end

    def group_condition
      return if @dedicated_pricings_only.blank?

      'AND pricings_pricings.group_id IN (:group_ids)'
    end

    def origin_condition
      return if @origin_nexus_id.blank?

      <<-SQL
       JOIN hubs as origin_hubs
         ON origin_hubs.nexus_id = :origin_nexus_id
         AND origin_hubs.tenant_id = :tenant_id
       JOIN stops AS origin_stops
         ON origin_stops.hub_id = origin_hubs.id
      SQL
    end

    def destination_condition
      return if @destination_nexus_id.blank?

      <<-SQL
        JOIN hubs as destination_hubs
          ON destination_hubs.nexus_id = :destination_nexus_id
          AND destination_hubs.tenant_id = :tenant_id
        JOIN stops AS destination_stops
          ON destination_stops.hub_id = destination_hubs.id
      SQL
    end

    def itinerary_condition
      return unless @origin_nexus_id.present? || @destination_nexus_id.present?

      condition = ''
      condition += 'AND itineraries.id = origin_stops.itinerary_id' if @origin_nexus_id
      condition += ' AND itineraries.id = destination_stops.itinerary_id' if @destination_nexus_id
      condition
    end
  end
end
