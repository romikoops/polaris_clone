# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::Pricing do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:pricing) { FactoryBot.create(:pricings_pricing, organization: organization) }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "itinerary_id" => pricing.itinerary_id,
          "group_id" => pricing.group_id,
          "cargo_class" => pricing.cargo_class,
          "tenant_vehicle_id" => pricing.tenant_vehicle_id,
          "effective_date" => pricing.effective_date.to_date,
          "expiration_date" => pricing.expiration_date.to_date,
          "row" => 2,
          "pricing_id" => nil,
          "organization_id" => organization.id
        }
      end

      it "returns the frame with the pricing_id" do
        expect(extracted_table["pricing_id"].to_a).to eq([pricing.id])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "itinerary_id" => nil,
          "group_id" => pricing.group_id,
          "cargo_class" => pricing.cargo_class,
          "tenant_vehicle_id" => pricing.tenant_vehicle_id,
          "effective_date" => pricing.effective_date,
          "expiration_date" => pricing.expiration_date,
          "row" => 2,
          "pricing_id" => nil,
          "organization_id" => organization.id
        }
      end

      it "does not find the record or add a pricing_id" do
        expect(extracted_table["pricing_id"].to_a).to eq([nil])
      end
    end
  end
end
