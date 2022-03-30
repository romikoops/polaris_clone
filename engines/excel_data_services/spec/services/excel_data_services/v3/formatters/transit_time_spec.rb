# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Formatters::TransitTime do
  include_context "V3 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:insertable_data) { result.insertable_data }

  describe "#insertable_data" do
    let(:row) do
      {
        "transit_time_id" => nil,
        "transit_time" => 15,
        "itinerary_id" => 3,
        "organization_id" => organization.id,
        "row" => 2,
        "tenant_vehicle_id" => 6
      }
    end
    let(:expected_data) do
      {
        "duration" => 15,
        "id" => nil,
        "itinerary_id" => 3,
        "tenant_vehicle_id" => 6
      }
    end

    it "returns the frame with the insertable_data" do
      expect(insertable_data.to_a.first).to eq(expected_data)
    end
  end
end
