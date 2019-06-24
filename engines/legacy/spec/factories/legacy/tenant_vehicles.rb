# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_tenant_vehicle, class: 'Legacy::TenantVehicle' do
    name { 'standard' }
    mode_of_transport { 'ocean' }
    association :tenant, factory: :legacy_tenant
    before(:create) do |tenant_vehicle|
      filter = tenant_vehicle.as_json(only: %i(mode_of_transport name))
      existing_vehicle = Legacy::Vehicle.where(filter).first
      tenant_vehicle.update(vehicle: existing_vehicle ||
        create(:legacy_vehicle,
               name: filter['name'],
               mode_of_transport: filter['mode_of_transport']))
    end
  end
end
