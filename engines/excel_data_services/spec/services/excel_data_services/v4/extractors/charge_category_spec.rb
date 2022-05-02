# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::ChargeCategory do
  include_context "V4 setup"

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

      it "does not find the record or add a charge_category_id" do
        expect(extracted_table["charge_category_id"].to_a).to eq([nil])
      end
    end
  end
end
