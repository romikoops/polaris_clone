# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::Context do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:pricing) { FactoryBot.create(:lcl_pricing, organization: organization) }
  let(:fee) { pricing.fees.first }
  let(:contex) do
    described_class.new(
      cbm_ratio: 1000.0,
      tenant_vehicle_id: 1376,
      cargo_class: "lcl",
      load_type: "cargo_item",
      origin_hub_id: 3603,
      destination_hub_id: 3604,
      direction: nil,
      margin_type: "freight_margin",
      effective_date: Time.zone.today,
      expiration_date: 2.weeks.from_now.to_date,
      vm_ratio: 1.0,
      context_id: context_id,
      rate_basis: "PER_WM",
      range_min: 0,
      range_max: Float::INFINITY,
      range_unit: "wm",
      charge_category_id: fee.charge_category_id,
      itinerary_id: 1277,
      code: "bas",
      rate: 1111.0,
      base: 1.0e-06,
      currency: "EUR",
      section: "cargo",
      organization_id: organization.id,
      load_meterage_ratio: nil,
      load_meterage_stackable_type: nil,
      load_meterage_non_stackable_type: nil,
      load_meterage_hard_limit: nil,
      load_meterage_stackable_limit: nil,
      load_meterage_non_stackable_limit: nil,
      km: nil,
      truck_type: nil,
      carrier_lock: false,
      source_id: context_id,
      source_type: source_type,
      min: 1.0,
      max: nil
    )
  end
  let(:source_type) { "Pricings::Pricing" }
  let(:context_id) { fee.pricing_id }

  describe "#original" do
    context "when the source was a Pricings::Pricing" do
      it "returns the source of the fee data" do
        expect(contex.original).to eq(fee.pricing)
      end
    end

    context "when the source was a Trucking::Trucking" do
      let(:source_type) { "Trucking::Trucking" }
      let(:trucking) { FactoryBot.create(:trucking_trucking, organization: organization) }
      let(:context_id) { trucking.id }

      it "returns the source of the fee data" do
        expect(contex.original).to eq(trucking)
      end
    end

    context "when the source was a Legacy::LocalCharge" do
      let(:source_type) { "Legacy::LocalCharge" }
      let(:trucking) { FactoryBot.create(:legacy_local_charge, organization: organization) }
      let(:context_id) { trucking.id }

      it "returns the source of the fee data" do
        expect(contex.original).to eq(trucking)
      end
    end
  end

  describe "#type" do
    it "returns the source_type" do
      expect(contex.type).to eq(source_type)
    end
  end

  describe "#charge_category" do
    it "returns the ChargeCategory based on the id" do
      expect(contex.charge_category).to eq(fee.charge_category)
    end
  end
end
