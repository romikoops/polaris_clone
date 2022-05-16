# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::DecoratedCharge do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:pricing) { FactoryBot.create(:pricings_pricing, organization: organization) }
  let(:context) do
    instance_double("OfferCalculator::Service::Charges::Context",
      organization_id: "c1cc1bfb-885d-40c7-ace2-7d5ac9735012",
      context_id: pricing.id,
      itinerary_id: pricing.itinerary_id,
      tenant_vehicle_id: pricing.tenant_vehicle_id,
      cargo_class: "lcl",
      load_type: "cargo_item",
      origin_hub_id: 9,
      destination_hub_id: 10,
      code: "bas",
      cbm_ratio: 1000.0,
      vm_ratio: 1.0,
      carrier_lock: false,
      carrier_id: pricing.tenant_vehicle.carrier_id,
      margin_type: "freight_margin",
      source_type: "Pricings::Pricing",
      effective_date: Date.parse("Tue, 03 May 2022"),
      expiration_date: Date.parse("Thu, 03 Nov 2022"),
      source_id: pricing.id,
      section: "cargo",
      direction: direction,
      truck_type: nil,
      metadata: { original_id: pricing.id })
  end
  let(:direction) { "export" }
  let(:rate_basis) { "PER_WM" }
  let(:measured_cargo) do
    instance_double("OfferCalculator::Service::MeasuredCargo",
      object: context,
      chargeable_weight_in_tons: Measured::Weight(2, "t"),
      volume: Measured::Volume.new(0.5, "m3"),
      quantity: 2,
      stackability: true,
      cargo_units: [instance_double(Journey::CargoUnit)])
  end
  let(:fee) do
    OfferCalculator::Service::Charges::Fee.new(
      rate: Money.from_amount(100, "USD"),
      charge_category_id: FactoryBot.create(:legacy_charge_categories).id,
      rate_basis: rate_basis,
      base: 0,
      minimum_charge: Money.from_amount(10, "USD"),
      maximum_charge: Money.from_amount(10_000, "USD"),
      range_min: 0,
      measure: 1.5,
      range_max: Float::INFINITY,
      surcharge: Money.from_amount(0, "USD")
    )
  end
  let(:charge) do
    OfferCalculator::Service::Charges::Charge.new(
      fee: fee,
      measured_cargo: measured_cargo
    )
  end
  let(:value) { charge.value }
  let(:decorated_charge) { described_class.new(charge: charge, value: value) }

  describe "#validity" do
    it "returns the `effective_date` and `expiration_date` values from the Context in Range form" do
      expect(decorated_charge.validity).to eq(Range.new(context.effective_date, context.expiration_date, exclude_end: true))
    end
  end

  describe "#tenant_vehicle" do
    it "returns the Legacy::TenantVehicle from the Context tenant_vehicle_id" do
      expect(decorated_charge.tenant_vehicle).to eq(pricing.tenant_vehicle)
    end
  end

  describe "#hub_id" do
    context "when the direction is `export`" do
      it "returns the `destination_hub_id` value from the Context (Pre-carriage rates store the hub id as 'destination_hub_id')" do
        expect(decorated_charge.hub_id).to eq(context.destination_hub_id)
      end
    end

    context "when the direction is `import`" do
      let(:direction) { "import" }

      it "returns the `origin_hub_id` value from the Context (On-carriage rates store the hub id as 'origin_hub_id')" do
        expect(decorated_charge.hub_id).to eq(context.origin_hub_id)
      end
    end
  end

  describe "#pricing_id" do
    it "returns the `context_id` value from the Context when the `source_type` is 'Pricings::Pricing'" do
      expect(decorated_charge.pricing_id).to eq(context.source_id)
    end

    context "when the `source_type` is not 'Pricings::Pricing'" do
      let(:context) { instance_double("OfferCalculator::Service::Charges::Context", source_type: "Other", source_id: "aaa") }

      it "returns nil" do
        expect(decorated_charge.pricing_id).to be_nil
      end
    end
  end

  describe "#chargeable_density" do
    context "when the `cargo_class` is `lcl`" do
      it "returns the chargeable weight in tons over the volume" do
        expect(decorated_charge.chargeable_density).to eq(measured_cargo.chargeable_weight_in_tons.value / measured_cargo.volume.value)
      end
    end

    context "when the `cargo_class` is `fcl_**`" do
      let(:context) { instance_double("OfferCalculator::Service::Charges::Context", cargo_class: "fcl_20") }

      it "returns the default value" do
        expect(decorated_charge.chargeable_density).to eq(described_class::FCL_CHARGEABLE_DENSITY)
      end
    end
  end

  describe "#targets" do
    context "when the rate_basis is 'PER_WM'" do
      it "returns the `measured_cargo`'s cargo_units" do
        expect(decorated_charge.targets).to eq(measured_cargo.cargo_units)
      end
    end

    context "when the rate_basis is one of the SHIPMENT_LEVEL_RATE_BASES" do
      let(:rate_basis) { "PER_SHIPMENT" }

      it "returns an empty array" do
        expect(decorated_charge.targets).to eq([])
      end
    end
  end

  describe "#breakdowns" do
    before do
      allow(OfferCalculator::Service::Charges::BreakdownBuilder).to receive(:new).and_return(breakdown_builder_double)
    end

    let(:breakdown_builder_double) do
      instance_double("OfferCalculator::Service::Charges::BreakdownBuilder",
        perform: instance_double("OfferCalculator::Service::Charges::Breakdown"))
    end

    it "returns an array of Breakdowns from the BreakdownBuilder service" do
      expect(decorated_charge.breakdowns).to eq(breakdown_builder_double.perform)
    end
  end

  describe "#rounded_value" do
    it "returns the value as is when there are no fractional cents" do
      expect(decorated_charge.rounded_value).to eq(value)
    end

    context "when the charge value is a fraction of the currency's base unit" do
      let(:value) { Money.new(0.75, "USD") }

      it "rounds the value to the nearest cent" do
        expect(decorated_charge.rounded_value).to eq(Money.new(1, "USD"))
      end
    end
  end

  describe "#unit_value" do
    it "returns the value divided by the number of units" do
      expect(decorated_charge.unit_value).to eq(value / measured_cargo.quantity)
    end

    context "when the charge unit_value results in a fraction of the currency's base unit" do
      let(:value) { Money.new(25, "USD") }

      it "rounds the value to the nearest cent" do
        expect(decorated_charge.unit_value).to eq(Money.new(13, "USD"))
      end
    end
  end

  context "when delegating to Context" do
    described_class::CONTEXT_DELEGATIONS.each do |method|
      it "delegates #{method} to context" do
        expect(decorated_charge.send(method)).to eq(context.send(method))
      end
    end
  end

  context "when delegating to Fee" do
    described_class::FEE_DELEGATIONS.each do |method|
      it "delegates #{method} to fee" do
        expect(decorated_charge.send(method)).to eq(fee.send(method))
      end
    end
  end

  context "when delegating to MeasuredCargo" do
    described_class::MEASURED_CARGO_DELEGATIONS.each do |method|
      it "delegates #{method} to measured_cargo" do
        expect(decorated_charge.send(method)).to eq(measured_cargo.send(method))
      end
    end
  end

  context "when duck typing OfferCalculator::Service::Calculators::Charge" do
    (OfferCalculator::Service::Calculators::Charge.instance_methods - Object.instance_methods).each do |method|
      it "responds to #{method}" do
        expect(decorated_charge).to respond_to(method)
      end
    end
  end
end
