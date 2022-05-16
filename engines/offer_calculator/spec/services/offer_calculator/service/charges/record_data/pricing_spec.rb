# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::RecordData::Pricing do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:result_frame) { described_class.new(record: pricing).perform }
  let(:period) { Range.new(Time.zone.today, 2.weeks.from_now.to_date) }
  let(:charge_category) { factory_charge_category_from(code: "bas", organization: organization) }
  let(:pricing) { FactoryBot.create(:pricings_pricing, organization: organization) }
  let(:expected_base) do
    { "cbm_ratio" => pricing.wm_rate,
      "tenant_vehicle_id" => pricing.tenant_vehicle_id,
      "cargo_class" => pricing.cargo_class,
      "load_type" => "cargo_item",
      "origin_hub_id" => pricing.itinerary.origin_hub_id,
      "destination_hub_id" => pricing.itinerary.destination_hub_id,
      "margin_type" => "freight_margin",
      "effective_date" => pricing.effective_date.to_date,
      "expiration_date" => pricing.expiration_date.to_date,
      "vm_ratio" => 1.0,
      "context_id" => pricing.id,
      "rate_basis" => fee.rate_basis.internal_code,
      "charge_category_id" => charge_category.id,
      "itinerary_id" => pricing.itinerary_id,
      "code" => charge_category.code,
      "range_max" => Float::INFINITY,
      "range_min" => 0,
      "min" => 1.0,
      "id" => nil,
      "section" => "cargo",
      "organization_id" => organization.id,
      "carrier_lock" => false,
      "carrier_id" => pricing.tenant_vehicle.carrier_id,
      "source_id" => pricing.id,
      "metadata" => fee.metadata,
      "source_type" => "Pricings::Pricing" }
  end

  before { Organizations.current_id = organization.id }

  context "without fees" do
    it "returns an empty data frame" do
      expect(result_frame).to be_empty
    end
  end

  context "with a PER_WM fee" do
    let!(:fee) { FactoryBot.create(:pricings_fee, :per_wm, charge_category: charge_category, pricing: pricing, organization: organization) }
    let(:expected_base_with_rate) do
      { "range_unit" => "wm",
        "rate" => fee.rate,
        "base" => fee.base,
        "currency" => fee.currency_name }.merge(expected_base)
    end

    it "returns the BAS fee flattened into a data frame" do
      expect(result_frame.to_a).to eq([expected_base_with_rate])
    end
  end

  context "with a PER_KG_RANGE fee" do
    let!(:fee) { FactoryBot.create(:pricings_fee, :per_kg_range, charge_category: charge_category, pricing: pricing, organization: organization) }
    let(:expected_range_values) do
      fee.range.map do |range|
        expected_base.merge({
          "range_min" => range["min"],
          "range_max" => range["max"],
          "range_unit" => "kg",
          "rate" => range["rate"],
          "base" => fee.base,
          "currency" => fee.currency_name
        })
      end
    end

    it "returns the range fee flattened into a data frame, one row per range" do
      expect(result_frame.to_a).to eq(expected_range_values)
    end
  end

  context "with a mixture of fees" do
    let(:thc_charge_category) { factory_charge_category_from(code: "thc", organization: organization) }
    let!(:fee) { FactoryBot.create(:pricings_fee, :per_wm, charge_category: charge_category, pricing: pricing, organization: organization) }
    let!(:range_fee) { FactoryBot.create(:pricings_fee, :per_kg_range, charge_category: thc_charge_category, pricing: pricing, organization: organization) }
    let(:expected_range_values) do
      range_fee.range.map do |range|
        expected_base.merge({
          "range_min" => range["min"],
          "range_max" => range["max"],
          "range_unit" => "kg",
          "rate" => range["rate"],
          "rate_basis" => range_fee.rate_basis.internal_code,
          "charge_category_id" => thc_charge_category.id,
          "code" => thc_charge_category.code,
          "base" => fee.base,
          "currency" => fee.currency_name
        })
      end
    end
    let(:expected_base_with_rate) do
      [{ "range_unit" => "wm",
         "rate" => fee.rate,
         "base" => fee.base,
         "currency" => fee.currency_name }.merge(expected_base)]
    end

    it "returns both fees flattened into a table with one row per range per fee" do
      expect(result_frame.to_a).to match_array(expected_range_values + expected_base_with_rate)
    end
  end
end
