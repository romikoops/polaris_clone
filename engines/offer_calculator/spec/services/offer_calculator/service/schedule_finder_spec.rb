# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::ScheduleFinder do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:address) { FactoryBot.create(:gothenburg_address) }
  let(:request) { FactoryBot.build(:offer_calculator_request, client: user, organization: organization) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:klass) { described_class.new(request: request) }
  let(:hubs) do
    {
      origin: Legacy::Hub.where(id: origin_hub.id),
      destination: Legacy::Hub.where(id: destination_hub.id)
    }
  end
  let(:routes) do
    [
      OfferCalculator::Route.new(
        itinerary_id: itinerary.id,
        origin_hub_id: itinerary.origin_hub_id,
        destination_hub_id: itinerary.destination_hub_id,
        tenant_vehicle_id: tenant_vehicle.id,
        mode_of_transport: "ocean"
      )
    ]
  end
  let(:departure_type) { "departure" }
  let(:results) { klass.perform(routes, 10, hubs) }
  let!(:trip) { FactoryBot.create(:trip_with_layovers, itinerary: itinerary, tenant_vehicle: tenant_vehicle) }
  let(:start_date) { request.cargo_ready_date + 1000.seconds }

  Timecop.freeze(Time.utc(2020, 1, 1, 0, 0, 0)) do
    before do
      Organizations::Organization.current_id = organization.id
      FactoryBot.create(:lcl_pricing,
        itinerary: itinerary,
        organization: organization,
        tenant_vehicle: tenant_vehicle)
      FactoryBot.create(:fcl_20_pricing,
        itinerary: itinerary,
        organization: organization,
        tenant_vehicle: tenant_vehicle)
      FactoryBot.create(:fcl_40_pricing,
        itinerary: itinerary,
        organization: organization,
        tenant_vehicle: tenant_vehicle)
      FactoryBot.create(:fcl_40_hq_pricing,
        itinerary: itinerary,
        organization: organization,
        tenant_vehicle: tenant_vehicle)
      organization.scope.update(content: { departure_query_type: departure_type })
      allow(request).to receive(:pickup_address).and_return(address)
    end

    describe ".perform" do
      context "without trucking" do
        before do
          allow(request).to receive(:pre_carriage?).and_return(false)
        end

        it "return the valid schedules" do
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results.first.origin_hub).to eq(origin_hub)
            expect(results.first.destination_hub).to eq(destination_hub)
          end
        end
      end

      context "with trucking" do
        before do
          allow(request).to receive(:pre_carriage?).and_return(true)
          google_directions = instance_double("Trucking::GoogleDirections")
          allow(Trucking::GoogleDirections).to receive(:new).and_return(google_directions)
          allow(google_directions).to receive(:driving_time_in_seconds).and_return(10_000)
          allow(google_directions).to receive(:driving_time_in_seconds_for_trucks).and_return(14_000)
        end

        it "return the valid schedules with pre_carriage" do
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results.first.origin_hub).to eq(origin_hub)
            expect(results.first.destination_hub).to eq(destination_hub)
          end
        end
      end

      context "with no driving time" do
        before do
          allow(request).to receive(:pre_carriage?).and_return(true)
          google_directions = instance_double("Trucking::GoogleDirections")
          allow(Trucking::GoogleDirections).to receive(:new).and_return(google_directions)
          allow(google_directions).to receive(:driving_time_in_seconds)
            .and_raise(Trucking::GoogleDirections::NoDrivingTime)
        end

        it "return raises an error when no driving time is found" do
          expect { klass.perform(routes, nil, hubs) }.to raise_error(OfferCalculator::Errors::NoDirectionsFound)
        end
      end
    end
  end
end
