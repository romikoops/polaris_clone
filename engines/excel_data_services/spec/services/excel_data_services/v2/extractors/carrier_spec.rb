# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Extractors::Carrier do
  include_context "for excel_data_services extractor setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:carrier) { FactoryBot.create(:legacy_carrier) }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "carrier" => carrier.code,
          "row" => 2
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
          "row" => 2
        }
      end

      let(:error_messages) do
        ["The carrier '#{row['carrier']}' cannot be found."]
      end

      it "appends an error to the state", :aggregate_failures do
        expect(result).to be_failed
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end
  end
end
