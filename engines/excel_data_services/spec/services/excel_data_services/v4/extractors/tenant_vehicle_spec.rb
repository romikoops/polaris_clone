# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::TenantVehicle do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let!(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "service" => tenant_vehicle.name,
          "carrier" => tenant_vehicle.carrier.name,
          "carrier_id" => tenant_vehicle.carrier_id,
          "mode_of_transport" => tenant_vehicle.mode_of_transport,
          "row" => 2,
          "organization_id" => organization.id
        }
      end

      it "returns the frame with the tenant_vehicle_id" do
        expect(extracted_table["tenant_vehicle_id"].to_a).to eq([tenant_vehicle.id])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "service" => "aaa",
          "carrier" => "bbb",
          "carrier_id" => 1222,
          "mode_of_transport" => "air",
          "row" => 2,
          "organization_id" => organization.id
        }
      end

      it "does not find the record or add a tenant_vehicle_id" do
        expect(extracted_table["tenant_vehicle_id"].to_a).to eq([nil])
      end
    end

    context "with multiple Organizations" do
      let!(:other_tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle) }
      let(:rows) do
        [{
          "service" => tenant_vehicle.name,
          "carrier" => tenant_vehicle.carrier.name,
          "carrier_id" => tenant_vehicle.carrier_id,
          "mode_of_transport" => tenant_vehicle.mode_of_transport,
          "row" => 2,
          "organization_id" => organization.id
        },
          {
            "service" => other_tenant_vehicle.name,
            "carrier" => other_tenant_vehicle.carrier.name,
            "carrier_id" => other_tenant_vehicle.carrier_id,
            "mode_of_transport" => other_tenant_vehicle.mode_of_transport,
            "row" => 3,
            "organization_id" => other_tenant_vehicle.organization_id
          }]
      end

      it "does not find the record or add a tenant_vehicle_id" do
        expect(extracted_table["tenant_vehicle_id"].to_a).to eq([tenant_vehicle.id, other_tenant_vehicle.id])
      end
    end
  end
end
