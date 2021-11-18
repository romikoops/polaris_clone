# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Formatters::TenantVehicle do
  include_context "for excel_data_services setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:insertable_data) { result.insertable_data }

  describe "#insertable_data" do
    context "when found" do
      let(:row) do
        {
          "service" => "standard",
          "carrier" => "MSC",
          "carrier_id" => 1,
          "mode_of_transport" => "ocean",
          "organization_id" => organization.id,
          "row" => 2,
          "tenant_vehicle_id" => nil
        }
      end
      let(:expected_data) do
        {
          "name" => "standard",
          "carrier_id" => 1,
          "mode_of_transport" => "ocean",
          "organization_id" => organization.id
        }
      end

      it "returns the frame with the insertable_data" do
        expect(insertable_data.to_a.first).to eq(expected_data)
      end
    end
  end
end
