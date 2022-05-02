# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::TransitTime do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization, mode_of_transport: "ocean") }
  let(:itinerary) { FactoryBot.create(:legacy_itinerary, organization: organization, mode_of_transport: "ocean") }
  let!(:transit_time) { FactoryBot.create(:legacy_transit_time, tenant_vehicle: tenant_vehicle, itinerary: itinerary) }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "itinerary_id" => itinerary.id,
          "tenant_vehicle_id" => tenant_vehicle.id,
          "mode_of_transport" => tenant_vehicle.mode_of_transport,
          "row" => 2
        }
      end

      it "returns the frame with the transit_time_id" do
        expect(extracted_table["transit_time_id"].to_a).to eq([transit_time.id])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "itinerary_id" => "abcde",
          "tenant_vehicle_id" => tenant_vehicle.id,
          "mode_of_transport" => tenant_vehicle.mode_of_transport,
          "row" => 2
        }
      end

      it "does not find the record or add a transit_time_id" do
        expect(extracted_table["transit_time_id"].to_a).to eq([nil])
      end
    end
  end
end
