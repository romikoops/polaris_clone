# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::DefaultCurrency do
  include_context "V4 setup"
  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }

  describe ".state" do
    context "when found" do
      let(:rows) do
        [
          {
            "currency" => "USD",
            "row" => 2,
            "organization_id" => organization.id
          },
          {
            "currency" => "CHF",
            "row" => 3,
            "organization_id" => organization.id
          }
        ]
      end

      it "returns the frame with the currencies" do
        expect(extracted_table["currency"].to_a).to match_array(%w[USD CHF])
      end
    end

    context "when not found" do
      let(:rows) do
        [{
          "currency" => nil,
          "row" => 2,
          "organization_id" => organization.id
        }]
      end

      it "returns the frame with the currency from the organization's default scope" do
        expect(extracted_table["currency"].to_a).to eq([organization.scope.default_currency])
      end
    end
  end
end
