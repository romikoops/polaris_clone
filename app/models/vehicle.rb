# frozen_string_literal: true

class Vehicle < ApplicationRecord
  has_many :transport_categories
  has_many :itineraries
  has_many :tenant_vehicles

  validates :name,
            presence: true,
            uniqueness: {
              scope: :mode_of_transport,
              message: ->(obj, _) { "'#{obj.name}' taken for mode of transport '#{obj.mode_of_transport}'" }
            }

  VEHICLE_NAMES = %w(ocean_default rail_default air_default truck_default).freeze
  TRANSPORT_CATEGORY_NAMES = %w(dry_goods liquid_bulk gas_bulk any).freeze
  CARGO_CLASSES = (%w(lcl) + Container::CARGO_CLASSES).freeze

  def self.create_from_name(name, mot, tenant_id, carrier_name)
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

  def create_all_transport_categories
    CARGO_CLASSES.each do |cargo_class|
      TRANSPORT_CATEGORY_NAMES.each do |transport_category_name|
        transport_category = TransportCategory.new(
          name: transport_category_name,
          mode_of_transport: mode_of_transport,
          cargo_class: cargo_class,
          vehicle: self
        )
        puts transport_category.errors.full_messages unless transport_category.save
      end
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
