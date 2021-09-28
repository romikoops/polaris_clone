# frozen_string_literal: true

require "rails_helper"

module Legacy
  RSpec.describe TenantVehicle, type: :model do
    let(:carrier) { FactoryBot.create(:legacy_carrier, name: "TEST") }
    let!(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier: carrier) }

    context "with valid data" do
      it "Creates a valid tenant vehicle" do
        expect(tenant_vehicle).to be_valid
      end
    end

    context "with duplicate data" do
      let(:duplicate) do
        FactoryBot.create(:legacy_tenant_vehicle,
          organization_id: tenant_vehicle.organization_id,
          mode_of_transport: tenant_vehicle.mode_of_transport,
          carrier_id: carrier.id,
          name: tenant_vehicle.name)
      end

      it "violates the uniqueness constraint" do
        expect { duplicate }.to raise_error { ActiveRecord::RecordInvalid }
      end
    end

    context "with a mix of duplicate and nil data" do
      let(:duplicate) do
        FactoryBot.build(:legacy_tenant_vehicle,
          organization_id: tenant_vehicle.organization_id,
          mode_of_transport: nil,
          carrier_id: carrier.id,
          name: tenant_vehicle.name)
      end

      it "the TenantVehicle is not valid without a mode of transport" do
        expect(duplicate).not_to be_valid
      end
    end

    describe ".with_carrier" do
      it "returns the tenant vehicle with carrier info" do
        target = tenant_vehicle.with_carrier
        aggregate_failures do
          expect(target.dig("carrier", "name")).to eq(carrier.name)
          expect(target.dig("carrier", "id")).to eq(carrier.id)
        end
      end
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
