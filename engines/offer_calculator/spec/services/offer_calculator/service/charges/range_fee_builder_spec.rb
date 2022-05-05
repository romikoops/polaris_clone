# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::RangeFeeBuilder do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:pricing) { FactoryBot.create(:lcl_pricing, organization: organization) }
  let(:fee) { pricing.fees.first }
  let(:margin_rows) do
    { "id" => [],
      "rate" => [],
      "operator" => [],
      "code" => [],
      "margin_id" => [],
      "applicable_id" => [],
      "applicable_type" => [],
      "effective_date" => [],
      "expiration_date" => [],
      "origin_hub_id" => [],
      "destination_hub_id" => [],
      "tenant_vehicle_id" => [],
      "pricing_id" => [],
      "cargo_class" => [],
      "margin_type" => [],
      "rank" => [] }
  end
  let(:source_type) { "Pricings::Pricing" }
  let(:context_id) { fee.pricing_id }
  let(:context) do
    instance_double("OfferCalculator::Service::Charges::Context",
      direction: direction,
      origin_hub_id: 1,
      destination_hub_id: 2,
      rate_basis: rate_basis,
      base: 0,
      effective_date: Time.zone.today,
      expiration_date: 2.weeks.from_now.to_date,
      tenant_vehicle_id: pricing.tenant_vehicle_id)
  end
  let(:rate_basis) { "PER_WM" }
  let(:measured_cargo) { instance_double(OfferCalculator::Service::Measurements::Cargo, scope: {}, object: context) }
  let(:ranged_fee) do
    described_class.new(
      fee_rows: Rover::DataFrame.new,
      margin_rows: Rover::DataFrame.new(margin_rows),
      measured_cargo: measured_cargo,
      range_type: "wm"
    ).perform
  end
  let(:direction) { "export" }

  before do
    allow(measured_cargo).to receive(:wm).and_return(instance_double("MeasuredValue", value: 1))
    allow(OfferCalculator::Service::Charges::RangeFinder).to receive(:new).and_return(range_finder)
    allow(OfferCalculator::Service::Charges::MarginedRate).to receive(:new).and_return(margined_rate)
  end

  describe "#perform" do
    context "when it successfully finds the range and applies margins" do
      let(:range_finder) do
        instance_double("OfferCalculator::Service::Charges::RangeFinder", fee: instance_double("OfferCalculator::Service::Charges::Fee", sourced_from_margin?: false, percentage?: false))
      end
      let(:margined_rate) do
        instance_double("OfferCalculator::Service::Charges::MarginedRate", margined_fee: instance_double("OfferCalculator::Service::Charges::Fee", parent: range_finder.fee, percentage?: false))
      end

      it "returns a Fee after filtering for ranges and applying Margins" do
        expect(ranged_fee).to eq(margined_rate.margined_fee)
      end
    end

    context "when it cant find the fee" do
      let(:range_finder) do
        instance_double("OfferCalculator::Service::Charges::RangeFinder", fee: nil)
      end
      let(:margined_rate) { nil }

      it "returns nil if no Fee is found" do
        expect(ranged_fee).to eq(nil)
      end
    end

    context "when the fee is `sourced_from_margin?`" do
      let(:range_finder) do
        instance_double("OfferCalculator::Service::Charges::RangeFinder", fee: instance_double("OfferCalculator::Service::Charges::Fee", sourced_from_margin?: true, percentage?: true, range_min: 1, range_max: 2))
      end
      let(:expected_margin_rows) do
        { "id" => [],
          "rate" => [],
          "operator" => [],
          "code" => [],
          "margin_id" => [],
          "applicable_id" => [],
          "applicable_type" => [],
          "effective_date" => [],
          "expiration_date" => [],
          "origin_hub_id" => [],
          "destination_hub_id" => [],
          "tenant_vehicle_id" => [],
          "pricing_id" => [],
          "cargo_class" => [],
          "margin_type" => [],
          "rank" => [] }
      end
      let(:margin) { FactoryBot.create(:pricings_margin, organization: organization) }
      let(:margin_rows) do
        { "id" => [margin.id],
          "rate" => [50],
          "operator" => ["+"],
          "code" => ["bas"],
          "margin_id" => [margin.id],
          "applicable_id" => [margin.applicable_id],
          "applicable_type" => [margin.applicable_type],
          "effective_date" => [margin.effective_date],
          "expiration_date" => [margin.expiration_date],
          "origin_hub_id" => [margin.origin_hub_id],
          "destination_hub_id" => [margin.destination_hub_id],
          "tenant_vehicle_id" => [margin.tenant_vehicle_id],
          "pricing_id" => [margin.pricing_id],
          "cargo_class" => ["lcl"],
          "source_id" => [margin.id],
          "source_type" => [margin.class.to_s],
          "margin_type" => ["freight_margin"],
          "range_min" => [1],
          "range_max" => [2],
          "rank" => [1] }
      end
      let(:margined_rate) do
        instance_double("OfferCalculator::Service::Charges::MarginedRate", margined_fee: instance_double("OfferCalculator::Service::Charges::Fee", parent: range_finder.fee, percentage?: false))
      end

      before do
        allow(OfferCalculator::Service::Charges::MarginedRate).to receive(:new).with(fee: range_finder.fee, margin_rows: margin_rows).and_return(margined_rate)
        ranged_fee
      end

      it "calls the  MarginedRate class without the Margin row used to build the fee" do
        expect(margined_rate).to have_received(:margined_fee)
      end
    end
  end
end
