# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::RouteFilter do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:carrier) { FactoryBot.create(:legacy_carrier) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier: carrier, organization: organization) }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
      load_type: "cargo_item",
      user: user,
      organization: organization)
  end
  let(:quotation) { FactoryBot.create(:quotations_quotation, legacy_shipment_id: shipment.id) }
  let(:cargo) { FactoryBot.create(:cargo_cargo, quotation_id: quotation.id) }
  let(:routes) do
    [
      OfferCalculator::Route.new(
        itinerary_id: itinerary.id,
        origin_stop_id: itinerary.stops.first.id,
        destination_stop_id: itinerary.stops.last.id,
        tenant_vehicle_id: tenant_vehicle.id,
        carrier_id: carrier.id,
        mode_of_transport: "ocean"
      )
    ]
  end
  let(:results) { described_class.new(shipment: shipment, quotation: quotation).perform(routes) }

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:lcl_pricing, itinerary: itinerary, organization: organization)
    FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, organization: organization)
    FactoryBot.create(:fcl_40_pricing, itinerary: itinerary, organization: organization)
    FactoryBot.create(:fcl_40_hq_pricing, itinerary: itinerary, organization: organization)
  end

  describe ".perform", :vcr do
    context "with Max dimensions" do
      before do
        FactoryBot.create(:legacy_max_dimensions_bundle, organization: organization)
        FactoryBot.create(:aggregated_max_dimensions_bundle, organization: organization)
      end

      context "with success" do
        before do
          FactoryBot.create(:lcl_unit,
            width_value: 0.990,
            height_value: 0.990,
            length_value: 0.990,
            weight_value: 2_000,
            cargo: cargo)
        end

        it "return the route detail hashes" do
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results).to match_array(routes)
          end
        end
      end

      context "with failure" do
        before do
          FactoryBot.create(:lcl_unit,
            width_value: 9.90,
            height_value: 9.90,
            length_value: 9.90,
            weight_value: 150_000,
            cargo: cargo)
        end

        it "raises InvalidRoutes when the routes are invalid" do
          expect {
            described_class.new(shipment: shipment, quotation: quotation).perform(routes)
          }.to raise_error(OfferCalculator::Errors::InvalidRoutes)
        end
      end

      context "with failure (AggregatedCargo)" do
        before do
          FactoryBot.create(:aggregated_unit,
            weight_value: 25_000,
            cargo: cargo)
        end

        it "raises InvalidRoutes when the routes are invalid" do
          expect {
            described_class.new(shipment: shipment, quotation: quotation).perform(routes)
          }.to raise_error(OfferCalculator::Errors::InvalidRoutes)
        end
      end

      context "with service specfic max dimensions (success)" do
        before do
          FactoryBot.create(:lcl_unit,
            width_value: 9.90,
            height_value: 9.90,
            length_value: 9.90,
            weight_value: 10_000,
            cargo: cargo)
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

        it "returns the valid routes" do
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results).to match_array(routes)
          end
        end
      end

      context "with carrier specfic max dimensions (success)" do
        before do
          FactoryBot.create(:lcl_unit,
            width_value: 9.90,
            height_value: 9.90,
            length_value: 9.90,
            weight_value: 10_000,
            cargo: cargo)
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

        it "returns the valid routes" do
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results).to match_array(routes)
          end
        end
      end

      context "with route specfic max dimensions (success)" do
        before do
          FactoryBot.create(:lcl_unit,
            width_value: 9.90,
            height_value: 9.90,
            length_value: 9.90,
            weight_value: 10_000,
            cargo: cargo)
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
        FactoryBot.create(:lcl_unit,
          width_value: 9.90,
          height_value: 9.90,
          length_value: 9.90,
          weight_value: 10_000,
          cargo: cargo)
        Legacy::MaxDimensionsBundle.destroy_all
      end

      it "passes when no max dimensions exist" do
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results).to match_array(routes)
        end
      end
    end
  end
end
