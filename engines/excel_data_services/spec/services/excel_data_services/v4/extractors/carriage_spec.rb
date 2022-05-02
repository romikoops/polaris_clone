# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::Carriage do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "direction" => "export",
          "row" => 2
        }
      end

      it "returns the frame with the carrier_id" do
        expect(extracted_table["carriage"].to_a).to eq(["pre"])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "carrier" => "AAA",
          "carrier_code" => "aaa",
          "row" => 2
        }
      end

      it "does not add a carrier_id" do
        expect(extracted_table["carriage"].to_a).to eq([nil])
      end
    end
  end
end
