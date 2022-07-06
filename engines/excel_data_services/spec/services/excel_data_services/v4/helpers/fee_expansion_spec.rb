# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Helpers::FeeExpansion do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:rates_and_metadata) do
    Rover::DataFrame.new(
      test_variants.map do |variant|
        {
          "truck_type" => "default",
          "carriage" => "pre",
          "cargo_class" => "lcl",
          "carrier" => "CarrierA",
          "service" => "standard",

          "organization_id" => organization.id,
          "rates" => {
            "kg" => [{ "rate" => { "currency" => "EUR", "rate_basis" => "PER_SHIPMENT", "rate" => 28.392 }, "min_kg" => 0.0, "max_kg" => 100.0, "min_value" => 0.0 }]
          }
        }.merge(variant)
      end
    )
  end
  let(:formatted_fee_variants) do
    Rover::DataFrame.new(
      fee_variants.map do |variant|
        { "organization_id" => organization.id,
          "truck_type" => "default",
          "carriage" => "pre",
          "zone" => nil,
          "cargo_class" => "lcl",
          "carrier" => "CarrierA",
          "service" => "standard",
          "fees" => formatted_fee }.merge(variant)
      end
    )
  end
  let(:formatted_fee) do
    { "FSC" => { "currency" => "EUR", "name" => "Fuel Surcharge Fee", "key" => "FSC", "shipment" => 30.0 } }
  end

  let(:header) { "identifier" }

  describe "#perform" do
    let(:result_frame) { described_class.new(formatted_fees: formatted_fee_variants, rates_and_metadata: rates_and_metadata).perform }

    context "with multiple zones and only default fees" do
      let(:test_variants) { [{ "zone" => "1.0" }, { "zone" => "2.0" }] }
      let(:fee_variants) { [{}] }

      it "returns a DataFrame each rate variant having the same fees" do
        expect(result_frame["fees"].to_a.uniq).to eq([formatted_fee])
      end
    end

    context "with multiple zones and one zoned fee" do
      let(:test_variants) { [{ "zone" => "1.0" }, { "zone" => "2.0" }] }
      let(:fee_variants) do
        [
          {},
          {
            "zone" => "1.0",
            "fees" => zone_1_fee_variant
          }
        ]
      end
      let(:zone_1_fee_variant) do
        formatted_fee.merge(
          { "THC" => { "currency" => "EUR", "name" => "Terminal Handling Charge", "key" => "THC", "wm" => 5 } }
        )
      end

      it "returns a DataFrame each rate variant having the same fees" do
        expect(result_frame.filter("zone" => "1.0")["fees"].to_a.uniq).to eq([zone_1_fee_variant])
      end
    end
  end
end
