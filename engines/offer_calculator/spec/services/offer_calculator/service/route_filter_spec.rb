# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::RouteFilter do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:request) { FactoryBot.build(:offer_calculator_request, client: user, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:carrier) { FactoryBot.create(:legacy_carrier) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier: carrier, organization: organization) }
  let(:routes) do
    [
      route
    ]
  end
  let(:route) {
    OfferCalculator::Route.new(
      itinerary_id: itinerary.id,
      origin_stop_id: itinerary.stops.first.id,
      destination_stop_id: itinerary.stops.last.id,
      tenant_vehicle_id: tenant_vehicle.id,
      carrier_id: carrier.id,
      mode_of_transport: "ocean"
    )
  }
  let(:date_range) { (Time.zone.today..2.weeks.from_now) }
  let(:results) { described_class.new(request: request, date_range: date_range).perform(routes: routes) }
  let(:cargo_units) do
    [FactoryBot.build(:journey_cargo_unit)]
  end

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:lcl_pricing,
      itinerary: itinerary,
      tenant_vehicle: tenant_vehicle,
      organization: organization)
    FactoryBot.create(:fcl_20_pricing,
      itinerary: itinerary,
      tenant_vehicle: tenant_vehicle,
      organization: organization)
    FactoryBot.create(:fcl_40_pricing,
      itinerary: itinerary,
      tenant_vehicle: tenant_vehicle,
      organization: organization)
    FactoryBot.create(:fcl_40_hq_pricing,
      itinerary: itinerary,
      tenant_vehicle: tenant_vehicle,
      organization: organization)
    allow(request).to receive(:cargo_units).and_return(cargo_units)
  end

  describe ".perform", :vcr do
    context "with Max dimensions" do
      before do
        FactoryBot.create(:legacy_max_dimensions_bundle, organization: organization)
        FactoryBot.create(:aggregated_max_dimensions_bundle, organization: organization)
      end

      context "with success" do
        let(:cargo_units) do
          [FactoryBot.build(:journey_cargo_unit,
            width_value: 0.990,
            height_value: 0.990,
            length_value: 0.990,
            weight_value: 2_000)]
        end

        it "return the route detail hashes" do
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results).to match_array(routes)
          end
        end
      end

      context "with failure" do
        let(:cargo_units) do
          [FactoryBot.build(:journey_cargo_unit,
            width_value: 9.90,
            height_value: 9.90,
            length_value: 9.90,
            weight_value: 150_000)]
        end

        it "raises InvalidRoutes when the routes are invalid" do
          expect {
            described_class.new(request: request, date_range: date_range).perform(routes: routes)
          }.to raise_error(OfferCalculator::Errors::InvalidRoutes)
        end
      end

      context "with failure (AggregatedCargo)" do
        let(:cargo_units) do
          [FactoryBot.build(:journey_cargo_unit,
            cargo_class: "aggregated_lcl",
            weight_value: 25000)]
        end

        it "raises InvalidRoutes when the routes are invalid" do
          expect {
            described_class.new(request: request, date_range: date_range).perform(routes: routes)
          }.to raise_error(OfferCalculator::Errors::InvalidRoutes)
        end
      end

      context "with service specfic max dimensions (success)" do
        before do
          [true, false].each do |aggregated|
            FactoryBot.create(:legacy_max_dimensions_bundle,
              aggregate: aggregated,
              width: 1000,
              height: 1000,
              length: 1000,
              payload_in_kg: 1_000_000,
              chargeable_weight: 1_000_000,
              tenant_vehicle_id: tenant_vehicle.id,
              carrier_id: carrier.id,
              mode_of_transport: "ocean",
              organization: organization)
          end
        end
        let(:cargo_units) do
          [FactoryBot.build(:journey_cargo_unit,
            quantity: 1,
            width_value: 9.90,
            height_value: 9.90,
            length_value: 9.90,
            weight_value: 10_000)]
        end

        it "returns the valid routes" do
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results).to match_array(routes)
          end
        end
      end

      context "with carrier specfic max dimensions (success)" do
        before do
          [true, false].each do |aggregated|
            FactoryBot.create(:legacy_max_dimensions_bundle,
              aggregate: aggregated,
              width: 1000,
              height: 1000,
              length: 1000,
              payload_in_kg: 1_000_000,
              chargeable_weight: 1_000_000,
              tenant_vehicle_id: nil,
              carrier_id: carrier.id,
              mode_of_transport: "ocean",
              organization: organization)
          end
        end

        let(:cargo_units) do
          [FactoryBot.build(:journey_cargo_unit,
            width_value: 9.90,
            height_value: 9.90,
            length_value: 9.90,
            quantity: 1,
            weight_value: 10_000)]
        end

        it "returns the valid routes" do
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results).to match_array(routes)
          end
        end
      end

      context "with route specfic max dimensions (success)" do
        before do
          [true, false].each do |aggregated|
            FactoryBot.create(:legacy_max_dimensions_bundle,
              aggregate: aggregated,
              width: 1000,
              length: 1000,
              height: 1000,
              payload_in_kg: 1_000_000,
              chargeable_weight: 1_000_000,
              tenant_vehicle_id: nil,
              carrier_id: nil,
              itinerary_id: itinerary.id,
              mode_of_transport: "ocean",
              organization: organization)
          end
        end

        let(:cargo_units) do
          [FactoryBot.build(:journey_cargo_unit,
            width_value: 9.90,
            height_value: 9.90,
            length_value: 9.90,
            quantity: 1,
            weight_value: 10_000)]
        end

        it "returns the valid routes" do
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results).to match_array(routes)
          end
        end
      end
    end

    context "when no max dimensions available" do
      before do
        Legacy::MaxDimensionsBundle.destroy_all
      end

      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          width_value: 9.90,
          height_value: 9.90,
          length_value: 9.90,
          weight_value: 10_000)]
      end

      it "passes when no max dimensions exist" do
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results).to match_array(routes)
        end
      end
    end

    context "when route has pricings valid in the near future" do
      let(:routes) do
        [
          route,
          OfferCalculator::Route.new(
            itinerary_id: other_itinerary.id,
            origin_stop_id: other_itinerary.stops.first.id,
            destination_stop_id: other_itinerary.stops.last.id,
            tenant_vehicle_id: other_tenant_vehicle.id,
            carrier_id: carrier.id,
            mode_of_transport: "ocean"
          )
        ]
      end
      let!(:other_tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
      let!(:other_itinerary) { FactoryBot.create(:default_itinerary, organization: organization) }
      let(:future_pricing) {
        FactoryBot.create(:lcl_pricing,
          itinerary: other_itinerary,
          tenant_vehicle: other_tenant_vehicle,
          effective_date: 1.week.from_now,
          expiration_date: 1.year.from_now,
          organization: organization)
      }

      it "passes both routes as valid even though one only has pricings valid in one week" do
        expect(results).to match_array(routes)
      end
    end
  end
end
