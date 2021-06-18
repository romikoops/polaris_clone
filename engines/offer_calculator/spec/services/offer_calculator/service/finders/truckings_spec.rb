# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Finders::Truckings do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:load_type) { "cargo_item" }
  let(:group) do
    FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
      FactoryBot.create(:groups_membership, member: user, group: tapped_group)
    end
  end
  let(:request) do
    FactoryBot.create(:offer_calculator_request,
      organization: organization,
      client: user,
      creator: user,
      params: params,
      cargo_trait: :lcl)
  end
  let(:params) do
    FactoryBot.build(:journey_request_params,
      :lcl,
      pickup_truck_type: "default",
      delivery_address: delivery_address,
      delivery_truck_type: "default",
      pickup_address: pickup_address,
      direction: "export",
      selected_day: 4.days.from_now.beginning_of_day.to_s)
  end
  let(:trips) do
    [
      FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle: tenant_vehicle_1)
    ]
  end
  let(:origin_location) do
    FactoryBot.create(:locations_location,
      bounds: FactoryBot.build(:legacy_bounds,
        lat: pickup_address.latitude, lng: pickup_address.longitude, delta: 0.4),
      country_code: "se")
  end
  let(:destination_location) do
    FactoryBot.create(:locations_location,
      bounds: FactoryBot.build(:legacy_bounds,
        lat: delivery_address.latitude, lng: delivery_address.longitude, delta: 0.4),
      country_code: "cn")
  end
  let(:pickup_address) { FactoryBot.create(:gothenburg_address, country: origin_hub.country) }
  let(:delivery_address) { FactoryBot.create(:shanghai_address, country: destination_hub.country) }
  let(:origin_trucking_location) {
    FactoryBot.create(:trucking_location, :with_location,
      location: origin_location, country: pickup_address.country)
  }
  let(:destination_trucking_location) {
    FactoryBot.create(:trucking_location, :with_location,
      location: destination_location, country: delivery_address.country)
  }
  let(:schedules) { trips.map { |trip| OfferCalculator::Schedule.from_trip(trip) } }
  let(:finder) {
    described_class.new(request: request, schedules: schedules)
  }
  let(:results) { finder.perform }
  let(:shipment_trucking) { {pre_carriage: {}, on_carriage: {}} }

  before do
    Organizations.current_id = organization.id
    allow(request).to receive(:pickup_address).and_return(pickup_address)
    allow(request).to receive(:delivery_address).and_return(delivery_address)
    FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location)
    FactoryBot.create(:lcl_on_carriage_availability, hub: destination_hub, query_type: :location)
    Geocoder::Lookup::Test.add_stub([pickup_address.latitude, pickup_address.longitude], [
      "address_components" => [{"types" => ["premise"]}],
      "address" => pickup_address.geocoded_address,
      "city" => pickup_address.city,
      "country" => pickup_address.country.name,
      "country_code" => pickup_address.country.code,
      "postal_code" => pickup_address.zip_code
    ])
    Geocoder::Lookup::Test.add_stub([delivery_address.latitude, delivery_address.longitude], [
      "address_components" => [{"types" => ["premise"]}],
      "address" => delivery_address.geocoded_address,
      "city" => delivery_address.city,
      "country" => delivery_address.country.name,
      "country_code" => delivery_address.country.code,
      "postal_code" => delivery_address.zip_code
    ])
  end

  describe ".perform" do
    context "when no trucking required" do
      before do
        FactoryBot.create(:trucking_trucking,
          hub: origin_hub, organization: organization, tenant_vehicle: tenant_vehicle_1)
        allow(request).to receive(:pre_carriage?).and_return(false)
        allow(request).to receive(:on_carriage?).and_return(false)
      end

      it "returns the no truckings" do
        aggregate_failures do
          expect(results).to be_a(ActiveRecord::Relation)
          expect(results.count).to eq(0)
        end
      end
    end

    context "when only origin trucking required on one itinerary" do
      let!(:trucking) {
        FactoryBot.create(:trucking_trucking,
          hub: origin_hub, organization: organization, tenant_vehicle: tenant_vehicle_1,
          location: origin_trucking_location)
      }
      before do
        allow(request).to receive(:pickup_address).and_return(pickup_address)
        allow(request).to receive(:pre_carriage?).and_return(true)
        allow(request).to receive(:on_carriage?).and_return(false)
      end

      it "returns the one trucking" do
        aggregate_failures do
          expect(results).to be_a(ActiveRecord::Relation)
          expect(results.count).to eq(1)
          expect(results.pluck(:id)).to match_array([trucking].map(&:id))
        end
      end
    end

    context "when only origin trucking required on one itinerary (group) (using default truck types)" do
      let!(:trucking) {
        FactoryBot.create(:trucking_trucking,
          hub: origin_hub, organization: organization, tenant_vehicle: tenant_vehicle_1,
          location: origin_trucking_location, group: group)
      }

      before do
        FactoryBot.create(:trucking_trucking,
          hub: origin_hub, organization: organization, tenant_vehicle: tenant_vehicle_1,
          location: origin_trucking_location)
        allow(request).to receive(:pickup_address).and_return(pickup_address)
        allow(request).to receive(:pre_carriage?).and_return(true)
        allow(request).to receive(:on_carriage?).and_return(false)
      end

      it "returns the one trucking" do
        aggregate_failures do
          expect(results).to be_a(ActiveRecord::Relation)
          expect(results.count).to eq(1)
          expect(results.pluck(:id)).to match_array([trucking].map(&:id))
        end
      end
    end

    context "when only origin trucking required on one itinerary (group) (using set truck types)" do
      let!(:trucking) {
        FactoryBot.create(:trucking_trucking, hub: origin_hub, organization: organization,
                                              tenant_vehicle: tenant_vehicle_1, location: origin_trucking_location,
                                              group: group)
      }

      before do
        FactoryBot.create(:trucking_trucking,
          hub: origin_hub, organization: organization, tenant_vehicle: tenant_vehicle_1,
          location: origin_trucking_location)
        allow(request).to receive(:pickup_address).and_return(pickup_address)
        allow(request).to receive(:pre_carriage?).and_return(true)
        allow(request).to receive(:on_carriage?).and_return(false)
      end

      it "returns the one trucking" do
        aggregate_failures do
          expect(results).to be_a(ActiveRecord::Relation)
          expect(results.count).to eq(1)
          expect(results.pluck(:id)).to match_array([trucking].map(&:id))
        end
      end
    end

    context "with trucking required on both ends one itinerary" do
      let!(:pre_carriage) {
        FactoryBot.create(:trucking_trucking, hub: origin_hub, organization: organization,
                                              tenant_vehicle: tenant_vehicle_1, location: origin_trucking_location)
      }
      let!(:on_carriage) {
        FactoryBot.create(:trucking_trucking, hub: destination_hub, carriage: "on",
                                              organization: organization, tenant_vehicle: tenant_vehicle_1,
                                              location: destination_trucking_location)
      }

      it "returns the both truckings trucking" do
        aggregate_failures do
          expect(results).to be_a(ActiveRecord::Relation)
          expect(results.count).to eq(2)
          expect(
            results.pluck(:id)
          ).to match_array([pre_carriage, on_carriage].map(&:id))
        end
      end
    end
  end
end
