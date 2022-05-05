# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::RelationData do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:period) { Range.new(Time.zone.today, 2.weeks.from_now.to_date) }
  let(:result_frame) { described_class.new(relation: relation, period: period).frame }
  let(:relation) { Legacy::LocalCharge.where(organization: organization) }
  let(:expected_base) do
    { "cbm_ratio" => Pricings::Pricing::WM_RATIO_LOOKUP[local_charge.mode_of_transport],
      "tenant_vehicle_id" => local_charge.tenant_vehicle_id,
      "carrier_id" => local_charge.tenant_vehicle.carrier_id,
      "cargo_class" => local_charge.load_type,
      "origin_hub_id" => local_charge.hub_id,
      "destination_hub_id" => local_charge.hub_id,
      "direction" => local_charge.direction,
      "context_id" => local_charge.id,
      "load_type" => "cargo_item",
      "margin_type" => "export_margin",
      "effective_date" => period.first,
      "expiration_date" => period.last,
      "vm_ratio" => 1,
      "rate_basis" => "PER_SHIPMENT",
      "charge_category_id" => charge_category.id,
      "itinerary_id" => nil,
      "code" => charge_category.code,
      "range_max" => Float::INFINITY,
      "range_min" => 0,
      "range_unit" => "shipment",
      "rate" => 17.5,
      "min" => 17.5,
      "base" => nil,
      "currency" => "EUR",
      "section" => "export",
      "organization_id" => organization.id,
      "load_meterage_ratio" => nil,
      "load_meterage_stackable_type" => nil,
      "load_meterage_non_stackable_type" => nil,
      "load_meterage_hard_limit" => nil,
      "load_meterage_stackable_limit" => nil,
      "load_meterage_non_stackable_limit" => nil,
      "km" => nil,
      "max" => nil,
      "truck_type" => nil,
      "carrier_lock" => false,
      "source_id" => local_charge.id,
      "source_type" => "Legacy::LocalCharge" }
  end
  let!(:local_charge) { FactoryBot.create(:legacy_local_charge, fees: fees, organization: organization) }

  before { Organizations.current_id = organization.id }

  context "with a PER_SHIPMENT fee" do
    let(:charge_category) { factory_charge_category_from(code: "solas", organization: organization) }
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
    let(:charge_category) { factory_charge_category_from(code: "qdf", organization: organization) }
    let!(:local_charge) { FactoryBot.create(:legacy_local_charge, fees: fees, organization: organization) }
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
    let(:expected_range_values) do
      [
        { "source_id" => local_charge.id, "range_min" => 0, "range_max" => 5, "rate" => 41, "range_unit" => "stowage", "rate_basis" => "PER_TON", "min" => 57, "max" => nil },
        { "source_id" => local_charge.id, "range_min" => 6, "range_max" => 40, "rate" => 8, "range_unit" => "stowage", "rate_basis" => "PER_CBM", "min" => 57, "max" => nil }
      ].map do |range|
        expected_base.merge(range)
      end
    end

    it "returns the range fee flattened into a data frame, one row per range" do
      expect(result_frame.to_a).to match_array(expected_range_values)
    end
  end
end
