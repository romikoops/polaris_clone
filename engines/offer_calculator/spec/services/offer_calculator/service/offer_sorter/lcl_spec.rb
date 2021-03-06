# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::OfferSorter do
  include_context "complete_route_with_trucking"
  include_context "offer_calculator_shared_context"

  let(:cargo_classes) { ["lcl"] }
  let(:load_type) { "cargo_item" }
  let(:cargo_trait) { :lcl }
  let(:request) { FactoryBot.build(:offer_calculator_request, cargo_trait: cargo_trait, organization: organization) }

  let(:pricing1) do
    FactoryBot.create(:lcl_pricing,
      organization: organization,
      itinerary: itinerary,
      effective_date: Time.zone.yesterday,
      expiration_date: 19.days.from_now,
      tenant_vehicle: tenant_vehicle)
  end
  let(:pricing2) do
    FactoryBot.create(:lcl_pricing,
      organization: organization,
      itinerary: itinerary,
      effective_date: 20.days.from_now,
      expiration_date: 40.days.from_now,
      tenant_vehicle: tenant_vehicle)
  end
  let(:pricings) do
    [pricing1, pricing2]
  end

  let(:charges) do
    raw_objects.flat_map do |raw_object|
      FactoryBot.build(:calculators_result_from_raw,
        raw_object: raw_object,
        request: request)
    end
  end

  let(:schedules) { trips[:trips].map { |trip| OfferCalculator::Schedule.from_trip(trip) } }
  let(:results) {
    described_class.sorted_offers(request: request, charges: charges, schedules: schedules)
  }

  context "with no valid responses" do
    let(:raw_objects) { [pricing1, pricing2] }
    let(:trips) do
      {trips: []}
    end

    it "raises an error" do
      expect { results }.to raise_error(OfferCalculator::Errors::NoValidOffers)
    end
  end

  context "with only freight and pricings split over period" do
    let(:raw_objects) { [pricing1, pricing2] }
    let(:trips) do
      FactoryBot.build(:trip_generator,
        organization: organization,
        itineraries: [itinerary],
        tenant_vehicles: [tenant_vehicle],
        days: [1, 7, 10, 15])
    end

    before do
      allow(request).to receive(:pre_carriage?).and_return(false)
      allow(request).to receive(:on_carriage?).and_return(false)
    end

    it "returns two sorted offers" do
      aggregate_failures do
        expect(results.length).to eq(2)
        expect(results.first.schedules.count).to eq(3)
        expect(results.second.schedules.count).to eq(1)
      end
    end
  end

  context "with end to end and pricings split by period" do
    let(:raw_objects) do
      [pricing1, pricing2] | local_charges | truckings
    end
    let(:trips) do
      FactoryBot.build(:trip_generator,
        organization: organization,
        itineraries: [itinerary],
        tenant_vehicles: [tenant_vehicle],
        days: [1, 7, 10, 15])
    end

    before do
      allow(request).to receive(:pre_carriage?).and_return(true)
      allow(request).to receive(:on_carriage?).and_return(true)
    end

    it "returns two sorted offers" do
      aggregate_failures do
        expect(results.length).to eq(2)
        expect(results.first.schedules.count).to eq(3)
        expect(results.second.schedules.count).to eq(1)
      end
    end
  end

  context "with parallel routes" do
    let(:pricing2) do
      FactoryBot.create(:lcl_pricing,
        organization: organization,
        itinerary: itinerary2,
        tenant_vehicle: tenant_vehicle2)
    end
    let(:raw_objects) do
      [pricing1, pricing2] | local_charges | local_charges2 | truckings | truckings2
    end
    let(:itinerary2) {
      FactoryBot.create(:felixstowe_shanghai_itinerary, organization: organization)
    }
    let(:tenant_vehicle2) {
      FactoryBot.create(:legacy_tenant_vehicle, name: "tv_2", organization: organization)
    }
    let(:local_charges2) do
      cargo_classes.flat_map do |cc|
        %w[import export].map do |direction|
          FactoryBot.create(:legacy_local_charge,
            direction: direction,
            hub: direction == "export" ? itinerary2.origin_hub : itinerary2.destination_hub,
            load_type: cc,
            organization: organization,
            tenant_vehicle: tenant_vehicle2)
        end
      end
    end
    let(:truckings2) do
      cargo_classes.flat_map do |cargo_class|
        [FactoryBot.create(:trucking_with_unit_rates,
          hub: itinerary2.origin_hub,
          organization: organization,
          cargo_class: cargo_class,
          load_type: load_type,
          truck_type: truck_type,
          tenant_vehicle: tenant_vehicle2,
          location: pickup_trucking_location),
          FactoryBot.create(:trucking_with_unit_rates,
            hub: itinerary2.destination_hub,
            organization: organization,
            cargo_class: cargo_class,
            load_type: load_type,
            truck_type: truck_type,
            tenant_vehicle: tenant_vehicle2,
            location: delivery_trucking_location,
            carriage: "on")]
      end
    end
    let(:trips) do
      FactoryBot.build(:trip_generator,
        organization: organization,
        itineraries: [itinerary, itinerary2],
        tenant_vehicles: [tenant_vehicle, tenant_vehicle2],
        days: [1, 7, 10, 15])
    end

    before do
      allow(request).to receive(:pre_carriage?).and_return(true)
      allow(request).to receive(:on_carriage?).and_return(true)
    end

    it "returns two sorted offers" do
      aggregate_failures do
        expect(results.length).to eq(4)
        expect(results.first.result["export"].length).to eq(1)
        expect(results.second.result["export"].length).to eq(1)
      end
    end
  end
end
