# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::Support::ChargeCategoryData do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:charge_category) { FactoryBot.create(:legacy_charge_categories, code: "puf", organization: organization) }
  let(:fee_rows) do
    [{ "code" => "puf", "rate_basis" => "PER_SHIPMENT", "rate" => "10" }]
  end
  let(:result) { described_class.new(frame: Rover::DataFrame.new(fee_rows)).perform }

  before { Organizations.current_id = organization.id }

  describe "#perform" do
    it "returns the frame with the charge category id appended to each relevant row" do
      expect(result["charge_category_id"]).to eq([charge_category.id])
    end

    context "when the charge category is not found" do
      let(:fee_rows) do
        [{ "code" => "puf", "rate_basis" => "PER_SHIPMENT", "rate" => "10" },
          { "code" => "solas", "rate_basis" => "PER_SHIPMENT", "rate" => "10" }]
      end

      it "returns only the rows with charge category data", :aggregate_failures do
        expect(result["charge_category_id"]).to eq([charge_category.id])
        expect(result.filter("code" => "solas")).to be_empty
      end
    end
  end
end
