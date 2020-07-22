# frozen_string_literal: true

module Legacy
  class Vehicle < ApplicationRecord
    self.table_name = 'vehicles'
    has_many :itineraries
    has_many :tenant_vehicles

    VEHICLE_NAMES = %w(ocean_default rail_default air_default truck_default).freeze
    CARGO_CLASSES = (%w(lcl) + Container::CARGO_CLASSES).freeze

    def self.create_from_name(name:, mot:, organization_id:, carrier_name: nil)
      vehicle = Vehicle.find_or_create_by!(name: name, mode_of_transport: mot)

      if carrier_name
        carrier = Carrier.find_or_create_by!(name: carrier_name)
        tv = carrier.tenant_vehicles.find_or_create_by(name: name, mode_of_transport: mot, vehicle_id: vehicle.id, organization_id: organization_id)
      else
        tv = TenantVehicle.find_or_create_by(name: name, mode_of_transport: mot, vehicle_id: vehicle.id, organization_id: organization_id)
      end

      tv
    end
  end
end

# == Schema Information
#
# Table name: vehicles
#
#  id                :bigint           not null, primary key
#  name              :string
#  mode_of_transport :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
