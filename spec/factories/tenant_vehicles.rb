# frozen_string_literal: true


FactoryBot.define do
  factory :tenant_vehicle do
    name 'standard'
    mode_of_transport 'ocean'
    association :tenant
    before(:create) do |tenant_vehicle|
      filter = tenant_vehicle.as_json(only: %i(mode_of_transport name))
      existing_vehicle = Vehicle.where(filter).first
      tenant_vehicle.update(vehicle: existing_vehicle || create(:vehicle))
    end
  end

end

# == Schema Information
#
# Table name: tenant_vehicles
#
#  id                :bigint(8)        not null, primary key
#  vehicle_id        :integer
#  tenant_id         :integer
#  is_default        :boolean
#  mode_of_transport :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  name              :string
#  carrier_id        :integer
#
