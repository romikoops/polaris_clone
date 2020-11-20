# frozen_string_literal: true

FactoryBot.define do
  factory :tenant_vehicle do
    name { "standard" }
    mode_of_transport { "ocean" }
    association :organization, factory: :organizations_organization
    before(:create) do |tenant_vehicle|
      filter = tenant_vehicle.as_json(only: %i[mode_of_transport name])
      existing_vehicle = Vehicle.where(filter).first
      tenant_vehicle.update(vehicle: existing_vehicle ||
        create(:vehicle, name: filter["name"], mode_of_transport: filter["mode_of_transport"]))
    end
  end
end

# == Schema Information
#
# Table name: tenant_vehicles
#
#  id                :bigint           not null, primary key
#  is_default        :boolean
#  mode_of_transport :string
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  carrier_id        :integer
#  organization_id   :uuid
#  sandbox_id        :uuid
#  tenant_id         :integer
#  vehicle_id        :integer
#
# Indexes
#
#  index_tenant_vehicles_on_organization_id  (organization_id)
#  index_tenant_vehicles_on_sandbox_id       (sandbox_id)
#  index_tenant_vehicles_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
