# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::RecordData::LocalCharge do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:result_frame) { described_class.new(record: local_charge).perform }
  let(:expected_base) do
    { "cbm_ratio" => Pricings::Pricing::WM_RATIO_LOOKUP[local_charge.mode_of_transport],
      "tenant_vehicle_id" => local_charge.tenant_vehicle_id,
      "cargo_class" => local_charge.load_type,
      "origin_hub_id" => local_charge.hub_id,
      "destination_hub_id" => local_charge.hub_id,
      "direction" => local_charge.direction,
      "context_id" => local_charge.id,
      "load_type" => "cargo_item",
      "margin_type" => "export_margin",
      "effective_date" => local_charge.effective_date.to_date,
      "expiration_date" => local_charge.expiration_date.to_date,
      "vm_ratio" => 1,
      "rate_basis" => "PER_SHIPMENT",
      "charge_category_id" => charge_category.id,
      "code" => charge_category.code,
      "key" => charge_category.code.upcase,
      "name" => charge_category.name,
      "range_max" => Float::INFINITY,
      "range_min" => 0,
      "range_unit" => "shipment",
      "rate" => 17.5,
      "min" => 17.5,
      "currency" => "EUR",
      "section" => "export",
      "organization_id" => organization.id,
      "max" => nil,
      "carrier_lock" => false,
      "carrier_id" => local_charge.tenant_vehicle.carrier_id,
      "source_id" => local_charge.id,
      "metadata" => local_charge.metadata,
      "source_type" => "Legacy::LocalCharge" }
  end
  let!(:local_charge) { FactoryBot.create(:legacy_local_charge, fees: fees, organization: organization) }
  let(:charge_category) { factory_charge_category_from(code: code, organization: organization) }

  before { Organizations.current_id = organization.id }

  context "with a PER_SHIPMENT fee" do
    let(:code) { "solas" }
    let(:fees) do
      {
        charge_category.code.upcase => {
          "key" => charge_category.code.upcase,
          "max" => nil,
          "min" => 17.5,
          "name" => charge_category.code.upcase,
          "rate" => 17.5,
          "currency" => "EUR",
          "rate_basis" => "PER_SHIPMENT"
        }
      }
    end

    it "returns the LocalCharge fee flattened into a data frame" do
      expect(result_frame.to_a).to eq([expected_base])
    end
  end

  context "with a PER_UNIT_TON_CBM_RANGE fee" do
    let(:fees) do
      {
        "QDF" =>
          { "key" => "QDF",
            "max" => nil,
            "min" => 57,
            "name" => "Wharfage / Quay Dues",
            "range" => [
              { "max" => 5, "min" => 0, "ton" => 41, "currency" => "EUR" },
              { "cbm" => 8, "max" => 40, "min" => 6, "currency" => "EUR" }
            ],
            "currency" => "EUR",
            "rate_basis" => "PER_UNIT_TON_CBM_RANGE" }
      }
    end
    let(:code) { "qdf" }
    let(:expected_base_with_ranges) do
      [
        { "range_min" => 0, "range_max" => 5, "rate" => 41, "range_unit" => "stowage", "rate_basis" => "PER_TON", "min" => 57, "max" => nil },
        { "range_min" => 6, "range_max" => 40, "rate" => 8, "range_unit" => "stowage", "rate_basis" => "PER_CBM", "min" => 57, "max" => nil }
      ].map do |range|
        expected_base.merge(range)
      end
    end

    it "returns the range fee flattened into a data frame, one row per range" do
      expect(result_frame.to_a).to eq(expected_base_with_ranges)
    end
  end

  context "with a mixture of fees" do
    let(:fees) do
      {
        other_charge_category.code.upcase =>
          { "key" => "KGR",
            "max" => nil,
            "min" => 57,
            "name" => "Kilo Fee",
            "range" => [
              { "max" => 5, "min" => 0, "kg" => 2, "currency" => "EUR" },
              { "min" => 6, "max" => 40, "kg" => 3, "currency" => "EUR" }
            ],
            "currency" => "EUR",
            "rate_basis" => "PER_KG_RANGE" },
        charge_category.code.upcase => {
          "key" => "THC",
          "max" => 100,
          "min" => 17.5,
          "name" => "Terminal Handling",
          "value" => 17.5,
          "base" => 100,
          "currency" => "EUR",
          "rate_basis" => "PER_X_KG"
        }
      }
    end
    let(:code) { "thc" }
    let(:other_charge_category) { factory_charge_category_from(code: "kgr", organization: organization) }
    let(:expected_base_with_ranges) do
      [
        { "charge_category_id" => other_charge_category.id, "range_min" => 0.0, "range_max" => 5.0, "rate" => 2.0, "range_unit" => "kg", "rate_basis" => "PER_KG_RANGE", "min" => 57, "max" => nil, "name" => "Kilo Fee", "key" => "KGR", "code" => "kgr", "base" => nil },
        { "charge_category_id" => other_charge_category.id, "range_min" => 6.0, "range_max" => 40.0, "rate" => 3.0, "range_unit" => "kg", "rate_basis" => "PER_KG_RANGE", "min" => 57, "max" => nil, "name" => "Kilo Fee", "key" => "KGR", "code" => "kgr", "base" => nil },
        { "charge_category_id" => charge_category.id, "rate" => 17.5, "range_unit" => "kg", "rate_basis" => "PER_X_KG", "min" => 17.5, "max" => 100, "name" => "Terminal Handling", "base" => 100 }
      ].map do |adjusted_rate_values|
        expected_base.merge(adjusted_rate_values)
      end
    end

    it "returns the range fee flattened into a data frame, one row per range" do
      expect(result_frame.to_a).to eq(expected_base_with_ranges)
    end
  end
end
