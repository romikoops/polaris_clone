# frozen_string_literal: true

module Validator
  class Itinerary
    attr_reader :itinerary, :tenant_vehicles, :origin_hub, :destination_hub, :date_range, :tenant_vehicle_lookup,
                :tenant, :groups, :pricings, :origin_local_charges, :destination_local_charges, :tenant_vehicles, :scope

    def initialize(itinerary:, user:)
      @itinerary = itinerary
      @origin_hub = itinerary.hubs.first
      @destination_hub = itinerary.hubs.last
      @legacy_tenant = itinerary.tenant
      @tenant = Tenants::Tenant.find_by(legacy_id: @legacy_tenant.id)
      @scope = Tenants::ScopeService.new(
        target: ::Tenants::User.find_by(legacy_id: user),
        tenant: ::Tenants::Tenant.find_by(legacy_id: itinerary.tenant.id)
      ).fetch
      @date_range = (Date.today..Date.today + 30.days)
    end

    def perform
      tenant_vehicles
      path_results
    end

    def pricings
      @pricings ||= Pricings::Pricing.where(itinerary: itinerary)
    end

    def origin_local_charges
      @origin_local_charges ||= Legacy::LocalCharge.where(hub: origin_hub, direction: 'export')
    end

    def destination_local_charges
      @destination_local_charges ||= Legacy::LocalCharge.where(hub: destination_hub, direction: 'import')
    end

    def groups
      ids = if scope['dedicated_pricings_only'] || scope['display_itineraries_with_rates']
              pricings.pluck(:group_id)
            else
              pricings.pluck(:group_id) | origin_local_charges.pluck(:group_id) | destination_local_charges.pluck(:group_id)
      end
      @groups ||= Tenants::Group.where(tenant: tenant, id: ids)
    end

    def group_ids
      groups.ids | [nil]
    end

    def tenant_vehicles
      @tenant_vehicle_lookup = group_ids.each_with_object(Hash.new { |h, k| h[k] = {} }) do |group_id, hash|
        freight = pricings.where(group_id: group_id).pluck(:tenant_vehicle_id, :cargo_class)
        origin = origin_local_charges.where(group_id: group_id).pluck(:tenant_vehicle_id, :load_type)
        destination = destination_local_charges.where(group_id: group_id).pluck(:tenant_vehicle_id, :load_type)
        hash[group_id] = (freight | origin | destination).uniq
        hash
      end
      @tenant_vehicles = Legacy::TenantVehicle.where(id: @tenant_vehicle_lookup.values.flatten.uniq)
    end

    def path_results
      tenant_vehicle_lookup.map do |group_id, tenant_vehicle_and_cargo_classes|
        results = tenant_vehicle_and_cargo_classes.map do |tenant_vehicle_id, cargo_class|
          load_type = %w[cargo_item lcl].include?(cargo_class) ? 'cargo_item' : 'container'
          {
            cargo_class: cargo_class,
            origin_local_charges: status_result(association: origin_local_charges.where(group_id: group_id, tenant_vehicle_id: tenant_vehicle_id, load_type: cargo_class)),
            destination_local_charges: status_result(association: destination_local_charges.where(group_id: group_id, tenant_vehicle_id: tenant_vehicle_id, load_type: cargo_class)),
            freight: status_result(association: pricings.where(group_id: group_id, tenant_vehicle_id: tenant_vehicle_id, cargo_class: cargo_class)),
            schedules: trip_status_result(trips: Legacy::Trip.where(itinerary: itinerary, tenant_vehicle_id: tenant_vehicle_id, load_type: load_type))
          }.merge(tenant_vehicle_info(tenant_vehicle_id: tenant_vehicle_id))
        end

        {
          group: group_info(group_id: group_id),
          results: results
        }
      end
    end

    def status_result(association:)
      association_is_empty = association.empty?
      date_adjusted_association = association.for_dates(date_range.first, date_range.last)
      association_is_expired = date_adjusted_association.empty?
      last_expiry = date_adjusted_association.order(expiration_date: :desc).first&.expiration_date
      status = if association_is_empty
                 'no_data'
               elsif !association_is_empty && association_is_expired
                 'expired'
               elsif last_expiry.present? && date_range.cover?(last_expiry)
                 'expiring_soon'
               else
                 'good'
        end
      {
        status: status,
        last_expiry: last_expiry,
        required: required_value(association: association)
      }
    end

    def required_value(association:)
      return true unless association.name == 'Legacy::LocalCharge'

      export_bool = association.where_values_hash['direction'] == 'export'
      target_hub = export_bool ? origin_hub : destination_hub
      carriage_value = export_bool ? 'pre' : 'on'
      charge_symbol = export_bool ? :export_charges : :import_charges
      trucking_exists = Trucking::Trucking.where(hub: target_hub, carriage: carriage_value).exists?
      mandatory_charge = Legacy::MandatoryCharge.find(target_hub.mandatory_charge_id)[charge_symbol]

      mandatory_charge || trucking_exists
    end

    def trip_status_result(trips:)
      association_is_empty = trips.empty?
      last_expiry = trips.order(start_date: :desc).first&.start_date
      status = if association_is_empty
                 'no_data'
               elsif last_expiry.present? && date_range.cover?(last_expiry)
                 'expiring_soon'
               else
                 'good'
        end
      {
        status: status,
        last_expiry: last_expiry,
        required: true
      }
    end

    def group_info(group_id:)
      return { name: 'Default', id: nil } if group_id.nil?

      groups.find(group_id)&.slice(:name, :id)
    end

    def tenant_vehicle_info(tenant_vehicle_id:)
      {
        service_level: tenant_vehicles.find(tenant_vehicle_id)&.name,
        carrier: tenant_vehicles.find(tenant_vehicle_id)&.carrier&.name || 'default'
      }
    end
  end
end
