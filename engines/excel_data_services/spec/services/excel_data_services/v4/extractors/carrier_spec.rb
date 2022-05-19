# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::Carrier do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:carrier) { FactoryBot.create(:legacy_carrier, name: "test") }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "carrier" => carrier.name,
          "carrier_code" => carrier.code,
          "row" => 2,
          "organization_id" => organization.id
        }
      end

      it "returns the frame with the carrier_id" do
        expect(extracted_table["carrier_id"].to_a).to eq([carrier.id])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "carrier" => "AAA",
          "carrier_code" => "aaa",
          "row" => 2,
          "organization_id" => organization.id
        }
      end

      it "does not add a carrier_id" do
        expect(extracted_table["carrier_id"].to_a).to eq([nil])
      end
    end
  end
end
