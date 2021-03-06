# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::OfferSorter do
  include_context "offer_calculator_shared_context"
  include_context "complete_route_with_trucking"

  let(:cargo_classes) { %w[fcl_20 fcl_40 fcl_40_hq] }
  let(:load_type) { "container" }
  let(:cargo_trait) { :fcl }
  let(:request) { FactoryBot.build(:offer_calculator_request, cargo_trait: cargo_trait, organization: organization) }
  let(:tenant_vehicle2) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:pricing_group1) do
    cargo_classes.map do |cargo_class|
      FactoryBot.create("#{cargo_class}_pricing".to_sym,
        organization: organization,
        itinerary: itinerary,
        effective_date: Time.zone.yesterday,
        expiration_date: 20.days.from_now,
        tenant_vehicle: tenant_vehicle)
    end
  end
  let(:pricing_group2) do
    cargo_classes.map do |cargo_class|
      FactoryBot.create("#{cargo_class}_pricing".to_sym,
        organization: organization,
        itinerary: itinerary,
        effective_date: 21.days.from_now,
        expiration_date: 40.days.from_now,
        tenant_vehicle: tenant_vehicle)
    end
  end

  let(:pricings) do
    pricing_group1 | pricing_group2
  end

  let(:charges) do
    raw_objects.flat_map do |raw_object|
      FactoryBot.build(:calculators_result_from_raw,
        raw_object: raw_object,
        request: request)
    end
  end
  let(:trips) do
    FactoryBot.build(:trip_generator,
      organization: organization,
      itineraries: [itinerary],
      tenant_vehicles: [tenant_vehicle],
      days: [1, 7, 10, 16])
  end

  let(:schedules) {
    trips[:trips].map { |trip| OfferCalculator::Schedule.from_trip(trip) }
  }
  let(:results) {
    described_class.sorted_offers(request: request,
                                  charges: charges, schedules: schedules)
  }

  context "with only freight and pricings split over period" do
    let(:raw_objects) { pricing_group1 | pricing_group2 }

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
      pricings | local_charges | truckings
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

  context "with multiple trucking options" do
    let(:trucking_tenant_vehicle_2) {
      FactoryBot.create(:legacy_tenant_vehicle, organization: organization, name: "trucking_2")
    }
    let(:other_truckings) do
      cargo_classes.flat_map do |cargo_class|
        [FactoryBot.create(:trucking_with_unit_rates,
          hub: origin_hub,
          organization: organization,
          cargo_class: cargo_class,
          load_type: load_type,
          truck_type: "chassis",
          tenant_vehicle: trucking_tenant_vehicle_2,
          location: pickup_trucking_location),
          FactoryBot.create(:trucking_with_unit_rates,
            hub: destination_hub,
            organization: organization,
            cargo_class: cargo_class,
            load_type: load_type,
            truck_type: "chassis",
            tenant_vehicle: trucking_tenant_vehicle_2,
            location: delivery_trucking_location,
            carriage: "on")]
      end
    end
    let(:raw_objects) do
      pricing_group1 | pricing_group2 | local_charges | truckings | other_truckings
    end

    before do
      allow(request).to receive(:pre_carriage?).and_return(true)
      allow(request).to receive(:on_carriage?).and_return(true)
    end

    context "with end to end and pricings and all permutations" do
      let(:trucking_tenant_vehicle_2) {
        FactoryBot.create(:legacy_tenant_vehicle, organization: organization, name: "trucking_2")
      }

      before do
        allow(request).to receive(:pre_carriage?).and_return(true)
        allow(request).to receive(:on_carriage?).and_return(true)
      end

      it "returns two sorted offers" do
        aggregate_failures do
          expect(results.length).to eq(8)
          expect(results.map { |r| r.schedules.count }.uniq).to match_array([3, 1])
        end
      end
    end

    context "with end to end and pricings and carrier_lock" do
      let(:carrier_lock) { true }

      before do
        allow(request).to receive(:pre_carriage?).and_return(true)
        allow(request).to receive(:on_carriage?).and_return(true)
      end

      it "returns two sorted offers" do
        aggregate_failures do
          expect(results.length).to eq(2)
          expect(results.map { |r| r.schedules.count }.uniq).to match_array([3, 1])
        end
      end
    end
  end
end
