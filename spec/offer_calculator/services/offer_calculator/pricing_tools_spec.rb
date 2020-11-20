# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::PricingTools do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:membership) { FactoryBot.create(:groups_membership, group: group, member: _user) }
  let(:shipment) {
    FactoryBot.create(:legacy_shipment, load_type: "cargo_item", user: user, organization: organization)
  }
  let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }

  describe ".calc_addon_charges" do
    let(:addon) { FactoryBot.create(:legacy_addon, organization_id: organization.id, hub: origin_hub) }
    let(:uknown_addon) { FactoryBot.create(:unknown_fee_addon, organization_id: organization.id, hub: origin_hub) }
    let(:addon_fcl) {
      FactoryBot.create(:legacy_addon, organization_id: organization.id, hub: origin_hub, cargo_class: "fcl_20")
    }
    let(:lcl) { FactoryBot.create(:legacy_cargo_item, shipment_id: shipment.id) }
    let(:fcl_20) { FactoryBot.create(:legacy_container, shipment_id: shipment.id) }

    it "calculates the addon charge for cargo item" do
      result = described_class.new(user: user, shipment: shipment)
        .calc_addon_charges(
          cargos: [lcl],
          charge: addon.fees,
          user: user,
          mode_of_transport: "ocean"
        )
      aggregate_failures do
        expect(result.dig("total", "value")).to eq(75)
        expect(result.dig("total", "currency")).to eq("EUR")
      end
    end

    it "calculates the addon charge for cargo item w/ unknown fee" do
      result = described_class.new(user: user, shipment: shipment)
        .calc_addon_charges(
          cargos: [lcl],
          charge: uknown_addon.fees,
          user: user,
          mode_of_transport: "ocean"
        )
      aggregate_failures do
        expect(result.dig("total", "value")).to eq(0)
        expect(result.dig("total", "currency")).to eq("EUR")
      end
    end

    it "calculates the addon charge for container" do
      result = described_class.new(user: user, shipment: shipment)
        .calc_addon_charges(
          cargos: [fcl_20],
          charge: addon_fcl.fees,
          user: user,
          mode_of_transport: "ocean"
        )
      aggregate_failures do
        expect(result.dig("total", "value")).to eq(75)
        expect(result.dig("total", "currency")).to eq("EUR")
      end
    end
  end

  describe ".fee_value" do
    let(:service) { described_class.new(user: user, shipment: shipment) }
    let(:value) { service.fee_value(fee: fee, cargo: cargo_hash) }
    let(:pricing) { FactoryBot.create(:pricings_pricing) }
    let(:cargo_hash) { {weight_measure: 1.344, volume: 1.344, weight: 1344, raw_weight: 1000, quantity: 1} }

    context "with CBM_TON_RANGE rate basis (in range && CBM)" do
      let(:fee) do
        {
          "key" => "QDF",
          "max" => nil,
          "min" => 20,
          "name" => "Wharfage / Quay Dues",
          "range" => [{"max" => 5, "min" => 0, "ton" => 41, "currency" => "EUR"},
            {"cbm" => 8, "max" => 14, "min" => 6, "currency" => "EUR"}],
          "currency" => "EUR",
          "rate_basis" => "PER_UNIT_TON_CBM_RANGE"
        }
      end
      let(:cargo_hash) do
        {
          volume: 6,
          weight: 500,
          raw_weight: 500,
          weight_measure: 6
        }
      end

      it "calculates the PER_CBM_TON_RANGE in favour of CBM" do
        expect(value).to eq(6 * 8)
      end
    end

    context "with CBM_TON_RANGE rate basis (in range && TON)" do
      let(:fee) do
        {
          "key" => "QDF",
          "max" => nil,
          "min" => 20,
          "name" => "Wharfage / Quay Dues",
          "range" => [{"max" => 5, "min" => 0, "ton" => 41, "currency" => "EUR"},
            {"cbm" => 8, "max" => 14, "min" => 6, "currency" => "EUR"}],
          "currency" => "EUR",
          "rate_basis" => "PER_UNIT_TON_CBM_RANGE"
        }
      end
      let(:cargo_hash) do
        {
          volume: 2,
          weight: 1000,
          raw_weight: 1000,
          weight_measure: 2
        }
      end

      it "calculates the PER_CBM_TON_RANGE in favour of TON" do
        expect(value).to eq(41)
      end
    end

    context "with CBM_TON_RANGE rate basis (out of range)" do
      let(:fee) do
        {
          "key" => "QDF",
          "max" => nil,
          "min" => 20,
          "name" => "Wharfage / Quay Dues",
          "range" => [{"max" => 5, "min" => 0, "ton" => 41, "currency" => "EUR"}],
          "currency" => "EUR",
          "rate_basis" => "PER_UNIT_TON_CBM_RANGE"
        }
      end
      let(:cargo_hash) do
        {
          volume: 6,
          weight: 500,
          raw_weight: 500,
          weight_measure: 6
        }
      end

      it "calculates the PER_CBM_TON_RANGE out of range" do
        expect(value).to eq(20)
      end
    end

    context "when calculates the PER_SHIPMENT_TON" do
      let(:fee) do
        {
          "key" => "THC",
          "max" => nil,
          "min" => 57,
          "rate" => 100,
          "name" => "A Fee",
          "currency" => "EUR",
          "rate_basis" => "PER_SHIPMENT_TON"
        }
      end
      let(:cargo_hash) do
        {
          volume: 2,
          weight: 2500,
          raw_weight: 2500,
          weight_measure: 2.5
        }
      end

      it "calculates the PER_SHIPMENT_TON" do
        expect(value).to eq(250)
      end
    end

    context "when calculates the PER_CBM_TON in favour of ton" do
      let(:fee) do
        {
          "key" => "THC",
          "max" => nil,
          "min" => 57,
          "ton" => 100,
          "cbm" => 100,
          "name" => "A Fee",
          "currency" => "EUR",
          "rate_basis" => "PER_CBM_TON"
        }
      end
      let(:cargo_hash) do
        {
          volume: 2,
          weight: 2500,
          raw_weight: 2500,
          weight_measure: 2.5
        }
      end

      it "calculates the PER_CBM_TON in favour of ton" do
        expect(value).to eq(250)
      end
    end

    context "when calculates the PER_CBM_TON in favour of cbm" do
      let(:fee) do
        {
          "key" => "THC",
          "max" => nil,
          "min" => 57,
          "ton" => 100,
          "cbm" => 100,
          "name" => "A Fee",
          "currency" => "EUR",
          "rate_basis" => "PER_CBM_TON"
        }
      end
      let(:cargo_hash) do
        {
          volume: 3,
          weight: 2500,
          raw_weight: 2500,
          weight_measure: 3
        }
      end

      it "calculates the PER_CBM_TON in favour of cbm" do
        expect(value).to eq(300)
      end
    end

    context "when calculates the PER_X_KG_FLAT" do
      let(:fee) do
        {
          "key" => "THC",
          "max" => nil,
          "min" => 57,
          "base" => 100,
          "value" => 50,
          "name" => "A Fee",
          "currency" => "EUR",
          "rate_basis" => "PER_X_KG_FLAT"
        }
      end
      let(:cargo_hash) do
        {
          volume: 3,
          weight: 2001,
          raw_weight: 2001,
          weight_measure: 3
        }
      end

      it "calculates the PER_X_KG_FLAT" do
        expect(value).to eq(0.105e6)
      end
    end

    context "with PER_CBM_RANGE_FLAT (larger volume)" do
      let(:fee) do
        {
          "key" => "THC",
          "rate" => 0.5e1,
          "rate_basis" => "PER_CBM_RANGE_FLAT",
          "currency" => "EUR",
          "min" => 0.5e1,
          "range" => [{"max" => 10.0, "min" => 0.0, "cbm" => 20}, {"max" => 100.0, "min" => 10.0, "cbm" => 11.0}]
        }.with_indifferent_access
      end
      let(:cargo_hash) { {weight_measure: 11, volume: 11, weight: 11_000, raw_weight: 11_000, quantity: 9} }

      it "returns the correct fee_range for the larger volume" do
        expect(value).to eq(11)
      end
    end

    context "with PER_CBM_RANGE_FLAT (smaller volume)" do
      let(:fee) do
        {
          "key" => "THC",
          "rate" => 0.5e1,
          "rate_basis" => "PER_CBM_RANGE_FLAT",
          "currency" => "EUR",
          "min" => 0.5e1,
          "range" => [{"max" => 10.0, "min" => 0.0, "cbm" => 20}, {"max" => 100.0, "min" => 10.0, "cbm" => 11.0}]
        }.with_indifferent_access
      end
      let(:cargo_hash) { {weight_measure: 4, volume: 4, raw_weight: 4000, weight: 4000, quantity: 9} }

      it "returns the correct fee_range for the smaller volume" do
        expect(value).to eq(20)
      end
    end

    context "with PER_WM_RANGE" do
      let(:fee) do
        {
          "rate" => 0.5e1,
          "rate_basis" => "PER_WM_RANGE",
          "currency" => "EUR",
          "min" => 0.5e1,
          "range" => [{"max" => 10.0, "min" => 0.0, "wm" => 5.0}, {"max" => 100.0, "min" => 10.0, "wm" => 10.0}]
        }
      end
      let(:cargo_hash) { {weight_measure: 11, volume: 11, weight: 11_000, raw_weight: 11_000, quantity: 9} }

      it "returns the correct fee_range for the weight_measure" do
        value = service.handle_range_fee(fee: fee, cargo: cargo_hash, metadata_id: nil)
        expect(value).to eq(110)
      end
    end

    context "with PER_CONTAINER" do
      let(:pricing_fee) { FactoryBot.create(:fee_per_container, pricing: pricing) }
      let(:fee) { pricing_fee.fee_data.as_json }

      it "returns the correct value" do
        expect(value).to eq(pricing_fee.rate * cargo_hash[:quantity])
      end
    end

    context "with PER_WM" do
      let(:pricing_fee) { FactoryBot.create(:fee_per_wm, pricing: pricing) }
      let(:fee) { pricing_fee.fee_data.as_json }

      it "returns the correct value" do
        expect(value).to eq(pricing_fee.rate * cargo_hash[:weight_measure])
      end
    end

    context "with PER_CBM" do
      let(:pricing_fee) { FactoryBot.create(:fee_per_cbm, pricing: pricing) }
      let(:fee) { pricing_fee.fee_data.as_json }

      it "returns the correct value" do
        expect(value).to eq(pricing_fee.rate * cargo_hash[:volume])
      end
    end

    context "with PER_KG" do
      let(:pricing_fee) { FactoryBot.create(:fee_per_kg, pricing: pricing) }
      let(:fee) { pricing_fee.fee_data.as_json }

      it "returns the correct value" do
        expect(value).to eq(pricing_fee.rate * cargo_hash[:weight])
      end
    end

    context "with PER_TON" do
      let(:pricing_fee) { FactoryBot.create(:fee_per_ton, pricing: pricing) }
      let(:fee) { pricing_fee.fee_data.as_json }

      it "returns the correct value" do
        expect(value).to eq(pricing_fee.rate * cargo_hash[:weight] / 1000.0)
      end
    end
  end
end
