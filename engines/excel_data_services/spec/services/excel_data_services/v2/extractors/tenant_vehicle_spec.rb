# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Extractors::TenantVehicle do
  include_context "for excel_data_services setup"

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
          "row" => 2
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
          "row" => 2
        }
      end

      let(:error_messages) do
        ["The service '#{row['service']} (#{row['carrier']})' cannot be found."]
      end

      it "appends an error to the state", :aggregate_failures do
        expect(result).to be_failed
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end
  end
end
