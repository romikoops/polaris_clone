# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::ChargesForCargo do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:query) { FactoryBot.create(:journey_query, client: user, organization: organization, cargo_count: 0) }
  let(:request) { FactoryBot.build(:offer_calculator_request, client: user, organization: organization, query: query) }
  let(:charges) { described_class.new(request: request, fee_rows: Rover::DataFrame.new(fee_rows), margins: Rover::DataFrame.new(margin_rows)).perform }
  let(:margin_rows) do
    Rover::DataFrame.new({ "id" => [],
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
      "rank" => [] })
  end

  let(:fee_rows) do
    [{ "cbm_ratio" => 1000.0,
       "tenant_vehicle_id" => 1071,
       "cargo_class" => fee_cargo_class,
       "load_type" => "cargo_item",
       "origin_hub_id" => 3009,
       "destination_hub_id" => 3010,
       "direction" => nil,
       "margin_type" => "freight_margin",
       "effective_date" => Time.zone.today,
       "expiration_date" => 2.weeks.from_now.to_date,
       "vm_ratio" => 1.0,
       "context_id" => "3f31408a-c579-4b28-9ef6-e4d462d20154",
       "rate_basis" => "PER_SHIPMENT",
       "range_min" => 0,
       "range_max" => Float::INFINITY,
       "range_unit" => "shipment",
       "charge_category_id" => 1127,
       "itinerary_id" => 1064,
       "code" => "bas",
       "rate" => 10,
       "base" => 1.0e-06,
       "currency" => "EUR",
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
       "source_id" => nil,
       "source_type" => "Pricings::Pricing",
       "id" => nil,
       "min" => 1.0 }]
  end

  before { Organizations.current_id = organization.id }

  describe "#perform" do
    context "when there a single CargoUnit of the matching class present" do
      let(:fee_cargo_class) { "lcl" }

      before { FactoryBot.create(:journey_cargo_unit, query: query) }

      it "build a Charge class for the one unit" do
        expect(charges.map(&:cargo_class)).to eq(["lcl"])
      end
    end

    context "when there a single AggregateLCL CargoUnit present and the fee is lcl based" do
      let(:fee_cargo_class) { "lcl" }

      before { FactoryBot.create(:journey_cargo_unit, :aggregate_lcl, query: query) }

      it "build a Charge class for the one unit, matching `aggregate_lcl` to `lcl`" do
        expect(charges.map(&:cargo_class)).to eq(["lcl"])
      end
    end

    context "when there are multiple cargo classes of CargoUnit present" do
      let(:fee_cargo_class) { "fcl_40" }
      let(:query) { FactoryBot.create(:journey_query, client: user, load_type: :fcl, organization: organization, cargo_count: 0) }

      before do
        %w[fcl_20 fcl_40 fcl_40_hq].each do |cargo_class|
          FactoryBot.create(:journey_cargo_unit, :fcl, cargo_class: cargo_class, query: query)
        end
        query.reload
      end

      it "build a Charge class for the one unit that matches the cargo class of the context" do
        expect(charges.map(&:cargo_class)).to eq(["fcl_40"])
      end
    end

    context "when there are no fees and only a margin" do
      let(:fee_cargo_class) { "lcl" }
      let(:margin) { FactoryBot.create(:pricings_margin, organization: organization, applicable: user) }
      let(:margin_rows) do
        [{
          "id" => margin.id,
          "rate" => 50,
          "operator" => "&",
          "code" => "bas",
          "margin_id" => margin.id,
          "applicable_id" => margin.applicable_id,
          "applicable_type" => margin.applicable_type,
          "effective_date" => margin.effective_date,
          "expiration_date" => margin.expiration_date,
          "origin_hub_id" => margin.origin_hub_id,
          "destination_hub_id" => margin.destination_hub_id,
          "tenant_vehicle_id" => margin.tenant_vehicle_id,
          "pricing_id" => margin.pricing_id,
          "cargo_class" => "lcl",
          "margin_type" => "freight_margin",
          "range_min" => 0,
          "range_max" => Float::INFINITY,
          "range_unit" => "unit",
          "currency" => "USD",
          "rank" => 1
        }]
      end
      let(:fee_rows) do
        {
          "rate" => [],
          "currency" => [],
          "charge_category_id" => [],
          "rate_basis" => [],
          "base" => [],
          "min" => [],
          "max" => [],
          "range_min" => [],
          "range_max" => [],
          "range_unit" => []
        }
      end

      before { FactoryBot.create(:journey_cargo_unit, query: query) }

      it "build a Charge class for the one unit" do
        expect(charges.map(&:cargo_class)).to eq(["lcl"])
      end
    end
  end
end
