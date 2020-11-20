# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Finders::Truckings do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:itinerary_1) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:origin_1) { itinerary_1.origin_hub }
  let(:destination_1) { itinerary_1.destination_hub }
  let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:load_type) { "cargo_item" }
  let(:group) do
    FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
      FactoryBot.create(:groups_membership, member: user, group: tapped_group)
    end
  end
  let(:shipment) {
    FactoryBot.create(:legacy_shipment,
      organization: organization, user: user, load_type: load_type, trucking: shipment_trucking)
  }
  let(:quotation) {
    FactoryBot.create(:quotations_quotation,
      legacy_shipment_id: shipment.id,
      pickup_address: gothenburg_address,
      delivery_address: shanghai_address)
  }
  let(:trips) do
    [
      FactoryBot.create(:legacy_trip, itinerary: itinerary_1, tenant_vehicle: tenant_vehicle_1)
    ]
  end
  let(:origin_location) do
    FactoryBot.create(:locations_location,
      bounds: FactoryBot.build(:legacy_bounds,
        lat: gothenburg_address.latitude, lng: gothenburg_address.longitude, delta: 0.4),
      country_code: "se")
  end
  let(:destination_location) do
    FactoryBot.create(:locations_location,
      bounds: FactoryBot.build(:legacy_bounds,
        lat: shanghai_address.latitude, lng: shanghai_address.longitude, delta: 0.4),
      country_code: "cn")
  end
  let(:gothenburg_address) { FactoryBot.create(:gothenburg_address) }
  let(:shanghai_address) { FactoryBot.create(:shanghai_address) }
  let(:origin_trucking_location) {
    FactoryBot.create(:trucking_location, :with_location,
      location: origin_location, country: gothenburg_address.country)
  }
  let(:destination_trucking_location) {
    FactoryBot.create(:trucking_location, :with_location,
      location: destination_location, country: shanghai_address.country)
  }
  let(:schedules) { trips.map { |trip| OfferCalculator::Schedule.from_trip(trip) } }
  let(:finder) {
    described_class.new(shipment: shipment, quotation: quotation, schedules: schedules)
  }
  let(:results) { finder.perform }
  let(:shipment_trucking) { {pre_carriage: {}, on_carriage: {}} }

  before do
    Organizations.current_id = organization.id
    FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_1, query_type: :location)
    FactoryBot.create(:lcl_on_carriage_availability, hub: destination_1, query_type: :location)
    Geocoder::Lookup::Test.add_stub([gothenburg_address.latitude, gothenburg_address.longitude], [
      "address_components" => [{"types" => ["premise"]}],
      "address" => gothenburg_address.geocoded_address,
      "city" => gothenburg_address.city,
      "country" => gothenburg_address.country.name,
      "country_code" => gothenburg_address.country.code,
      "postal_code" => gothenburg_address.zip_code
    ])
    Geocoder::Lookup::Test.add_stub([shanghai_address.latitude, shanghai_address.longitude], [
      "address_components" => [{"types" => ["premise"]}],
      "address" => shanghai_address.geocoded_address,
      "city" => shanghai_address.city,
      "country" => shanghai_address.country.name,
      "country_code" => shanghai_address.country.code,
      "postal_code" => shanghai_address.zip_code
    ])
  end

  describe ".perform" do
    context "when no trucking required" do
      before do
        FactoryBot.create(:trucking_trucking,
          hub: origin_1, organization: organization, tenant_vehicle: tenant_vehicle_1)
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
          hub: origin_1, organization: organization, tenant_vehicle: tenant_vehicle_1,
          location: origin_trucking_location)
      }
      let(:shipment_trucking) {
        {pre_carriage: {address_id: gothenburg_address.id, truck_type: "default"}}
      }

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
          hub: origin_1, organization: organization, tenant_vehicle: tenant_vehicle_1,
          location: origin_trucking_location, group: group)
      }
      let(:shipment_trucking) { {pre_carriage: {address_id: gothenburg_address.id}} }

      before do
        FactoryBot.create(:trucking_trucking,
          hub: origin_1, organization: organization, tenant_vehicle: tenant_vehicle_1,
          location: origin_trucking_location)
        allow(shipment).to receive(:has_pre_carriage?).and_return(true)
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
        FactoryBot.create(:trucking_trucking, hub: origin_1, organization: organization,
                                              tenant_vehicle: tenant_vehicle_1, location: origin_trucking_location,
                                              group: group)
      }
      let(:shipment_trucking) {
        {pre_carriage: {address_id: gothenburg_address.id, truck_type: "default"}}
      }

      before do
        FactoryBot.create(:trucking_trucking,
          hub: origin_1, organization: organization, tenant_vehicle: tenant_vehicle_1,
          location: origin_trucking_location)
        allow(shipment).to receive(:has_pre_carriage?).and_return(true)
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
        FactoryBot.create(:trucking_trucking, hub: origin_1, organization: organization,
                                              tenant_vehicle: tenant_vehicle_1, location: origin_trucking_location)
      }
      let!(:on_carriage) {
        FactoryBot.create(:trucking_trucking, hub: destination_1, carriage: "on",
                                              organization: organization, tenant_vehicle: tenant_vehicle_1,
                                              location: destination_trucking_location)
      }
      let(:shipment_trucking) do
        {
          pre_carriage: {address_id: gothenburg_address.id, truck_type: "default"},
          on_carriage: {address_id: shanghai_address.id, truck_type: "default"}
        }
      end

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
