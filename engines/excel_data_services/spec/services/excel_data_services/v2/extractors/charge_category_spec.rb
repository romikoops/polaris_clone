# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Extractors::ChargeCategory do
  include_context "for excel_data_services setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:charge_category) { FactoryBot.create(:legacy_charge_categories, organization: organization) }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "fee_code" => charge_category.code,
          "fee_name" => charge_category.name,
          "row" => 2
        }
      end

      it "returns the frame with the charge_category_id" do
        expect(extracted_table["charge_category_id"].to_a).to eq([charge_category.id])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "fee_code" => "AAA",
          "fee_name" => "BBBB",
          "row" => 2
        }
      end

      let(:error_messages) do
        ["The charge '#{row['fee_code']} - #{row['fee_name']}' cannot be found."]
      end

      it "appends an error to the state", :aggregate_failures do
        expect(result).to be_failed
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end
  end
end
