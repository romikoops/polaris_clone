# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::Currency do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }

  before { FactoryBot.create(:treasury_exchange_rate) }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "row" => 2,
          "currency" => "eur",
          "organization_id" => organization.id
        }
      end

      it "returns the frame with the user id" do
        expect(extracted_table["currency"].to_a).to eq(["eur"])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "row" => 3,
          "currency" => "czk",
          "organization_id" => organization.id
        }
      end

      it "does not find the exchange rate" do
        expect(extracted_table["existing_currency"].to_a).to eq([nil])
      end
    end
  end
end
