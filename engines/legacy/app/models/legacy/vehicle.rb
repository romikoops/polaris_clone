# frozen_string_literal: true

module Legacy
  class Vehicle < ApplicationRecord
    self.table_name = 'vehicles'
    has_many :transport_categories
    has_many :itineraries
    has_many :tenant_vehicles

    def self.create_from_name(name:, mot:, tenant_id:, carrier_name: nil, sandbox: nil)
      vehicle = Vehicle.find_or_create_by!(name: name, mode_of_transport: mot)
  
      if carrier_name
        carrier = Carrier.find_or_create_by!(name: carrier_name)
        tv = carrier.tenant_vehicles.find_or_create_by(name: name, mode_of_transport: mot, vehicle_id: vehicle.id, tenant_id: tenant_id)
      else
        tv = TenantVehicle.find_or_create_by(name: name, mode_of_transport: mot, vehicle_id: vehicle.id, tenant_id: tenant_id)
      end
  
      if vehicle.transport_categories.none?
        CARGO_CLASSES.each do |cargo_class|
          this_class = cargo_class.clone
          TRANSPORT_CATEGORY_NAMES.each do |transport_category_name|
            transport_category = TransportCategory.create(
              name: transport_category_name,
              mode_of_transport: mot,
              cargo_class: this_class,
              vehicle: vehicle
            )
            puts transport_category.errors.full_messages if transport_category.errors.any?
          end
        end
      end
  
      tv
    end
  end
end

# == Schema Information
#
# Table name: vehicles
#
#  id                :bigint(8)        not null, primary key
#  name              :string
#  mode_of_transport :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
