# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Extractors::RateBasis do
  include_context "for excel_data_services setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:rate_basis) { FactoryBot.create(:pricings_rate_basis) }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "rate_basis" => rate_basis.external_code,
          "row" => 2
        }
      end

      it "returns the frame with the rate_basis_id" do
        expect(extracted_table["rate_basis_id"].to_a).to eq([rate_basis.id])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "rate_basis" => "AAA",
          "row" => 2
        }
      end

      let(:error_messages) do
        ["The Rate Basis '#{row['rate_basis']}' is not recognized."]
      end

      it "appends an error to the state", :aggregate_failures do
        expect(result).to be_failed
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end
  end
end
