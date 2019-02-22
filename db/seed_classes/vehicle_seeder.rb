# frozen_string_literal: true

class VehicleSeeder
  VEHICLE_NAMES = %w(
    ocean_default
    rail_default
    air_default
    truck_default
  ).freeze
  TRANSPORT_CATEGORY_NAMES = %w(
    dry_goods
    liquid_bulk
    gas_bulk
    any
  ).freeze
  CARGO_CLASSES = %w(
    fcl_20
    fcl_40
    fcl_40_hq
    lcl
  ).freeze

  def self.perform(filter = {})
    Tenant.where(filter).each do |tenant|
      VEHICLE_NAMES.each do |vehicle_name|
        mot = vehicle_name.split('_')[0]
        vehicle = Vehicle.find_or_create_by(name: vehicle_name, mode_of_transport: mot)
        tenant.tenant_vehicles.find_or_create_by(
          name: vehicle_name, mode_of_transport: mot, vehicle_id: vehicle.id
        )

        CARGO_CLASSES.each do |cargo_class|
          TRANSPORT_CATEGORY_NAMES.each do |transport_category_name|
            transport_category = TransportCategory.find_or_create_by(
              name: transport_category_name,
              mode_of_transport: mot,
              cargo_class: cargo_class,
              vehicle: vehicle
            )
          end
        end
      end
    end
  end
end
