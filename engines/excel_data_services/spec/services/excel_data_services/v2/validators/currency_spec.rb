# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Validators::Currency do
  include_context "for excel_data_services setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }

  before { FactoryBot.create(:treasury_exchange_rate) }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "row" => 2,
          "currency" => "eur"
        }
      end

      it "returns the frame with the country_id" do
        expect(extracted_table["currency"].to_a).to eq(["eur"])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "row" => 2,
          "currency" => "czk"
        }
      end

      let(:error_messages) do
        ["The currency 'czk' is not valid under the ISO4217 standard"]
      end

      it "appends an error to the state", :aggregate_failures do
        expect(result.errors).to be_present
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end
  end
end
