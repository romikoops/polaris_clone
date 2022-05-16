# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::RelationData do
  let(:result_frame) { described_class.new(relation: relation, period: period).frame }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:period) { Range.new(Time.zone.today, 2.weeks.from_now.to_date) }
  let(:relation) { Pricings::Pricing.where(organization: organization) }
  let(:pricing) { FactoryBot.create(:pricings_pricing, organization: organization) }
  let(:charge_category) { factory_charge_category_from(code: "bas", organization: organization) }
  let!(:fee) { FactoryBot.create(:pricings_fee, :per_wm, charge_category: charge_category, pricing: pricing, organization: organization) }
  let(:expected_base) do
    { "cbm_ratio" => pricing.wm_rate,
      "tenant_vehicle_id" => pricing.tenant_vehicle_id,
      "carrier_id" => pricing.tenant_vehicle.carrier_id,
      "cargo_class" => pricing.cargo_class,
      "load_type" => "cargo_item",
      "origin_hub_id" => pricing.itinerary.origin_hub_id,
      "destination_hub_id" => pricing.itinerary.destination_hub_id,
      "direction" => nil,
      "margin_type" => "freight_margin",
      "effective_date" => period.first,
      "expiration_date" => period.last,
      "vm_ratio" => 1.0,
      "context_id" => pricing.id,
      "rate_basis" => fee.rate_basis.internal_code,
      "charge_category_id" => charge_category.id,
      "itinerary_id" => pricing.itinerary_id,
      "code" => charge_category.code,
      "range_max" => Float::INFINITY,
      "range_min" => 0,
      "range_unit" => "wm",
      "rate" => fee.rate,
      "base" => fee.base,
      "currency" => fee.currency_name,
      "min" => 1.0,
      "section" => "cargo",
      "organization_id" => organization.id,
      "load_meterage_ratio" => nil,
      "load_meterage_stackable_type" => nil,
      "load_meterage_non_stackable_type" => nil,
      "load_meterage_hard_limit" => nil,
      "load_meterage_stackable_limit" => nil,
      "load_meterage_non_stackable_limit" => nil,
      "km" => nil,
      "truck_type" => nil,
      "carrier_lock" => false,
      "source_id" => pricing.id,
      "metadata" => fee.metadata,
      "source_type" => "Pricings::Pricing",
      "max" => nil }
  end

  before { Organizations.current_id = organization.id }

  context "with a PER_WM fee" do
    it "returns the BAS fee flattened into a data frame" do
      expect(result_frame.to_a).to eq([expected_base])
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
          "rate" => range["rate"]
        })
      end
    end

    it "returns the range fee flattened into a data frame, one row per range" do
      expect(result_frame.to_a).to eq(expected_range_values)
    end
  end
end
