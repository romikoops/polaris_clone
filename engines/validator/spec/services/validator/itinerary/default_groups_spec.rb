# frozen_string_literal: true

require "rails_helper"

RSpec.describe Validator::Itinerary do
  describe "#perform" do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:user) { FactoryBot.create(:users_client, organization: organization) }
    let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
    let(:carrier_1) { FactoryBot.create(:legacy_carrier, name: "TCR") }
    let(:default_tenant_vehicle) {
      FactoryBot.create(:legacy_tenant_vehicle, organization: organization,
                                                name: "Default", carrier: carrier_1)
    }
    let(:origin_hub) { itinerary.hubs.first }
    let(:destination_hub) { itinerary.hubs.last }

    let!(:pricing_1) do
      FactoryBot.create(:lcl_pricing,
        organization: organization,
        tenant_vehicle_id: default_tenant_vehicle.id,
        itinerary: itinerary,
        effective_date: DateTime.now.beginning_of_minute,
        expiration_date: 90.days.from_now.beginning_of_minute)
    end
    let!(:origin_local_charge) do
      FactoryBot.create(:legacy_local_charge,
        organization: organization,
        direction: "export",
        tenant_vehicle_id: default_tenant_vehicle.id,
        hub: origin_hub,
        effective_date: DateTime.now.beginning_of_minute,
        expiration_date: 90.days.from_now.beginning_of_minute)
    end
    let!(:destination_local_charge) do
      FactoryBot.create(:legacy_local_charge,
        organization: organization,
        direction: "import",
        tenant_vehicle_id: default_tenant_vehicle.id,
        hub: destination_hub,
        effective_date: DateTime.now.beginning_of_minute,
        expiration_date: 90.days.from_now.beginning_of_minute)
    end
    let!(:trip) {
      FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle_id: default_tenant_vehicle.id,
                                      load_type: "cargo_item")
    }
    let(:result) { described_class.new(user: user, itinerary: itinerary).perform }

    context "with one tenant vehicle chain" do
      let(:target_result) { result.first[:results].find { |res| res[:service_level] == default_tenant_vehicle.name } }

      it "returns the expected result for one tenant vehicle chain", :aggregate_failures do
        expect(
          target_result.dig(:origin_local_charges)
        ).to eq(required: false, status: "good", last_expiry: origin_local_charge.expiration_date.beginning_of_minute)
        expect(
          target_result.dig(:destination_local_charges)
        ).to eq(required: false, status: "good",
                last_expiry: destination_local_charge.expiration_date.beginning_of_minute)
        expect(
          target_result.dig(:freight)
        ).to eq(required: true, status: "good", last_expiry: pricing_1.expiration_date.beginning_of_minute)
        expect(
          target_result.dig(:schedules)
        ).to eq(required: true, status: "expiring_soon", last_expiry: trip.start_date)
      end
    end

    context "with one tenant vehicle chain with invalid Local Charges and no Trips" do
      let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
      let(:target_result) { result.first[:results].find { |res| res[:service_level] == tenant_vehicle_2.name } }

      before do
        FactoryBot.create(:lcl_pricing,
          organization: organization,
          tenant_vehicle_id: tenant_vehicle_2.id,
          itinerary: itinerary,
          effective_date: 20.days.ago.beginning_of_minute,
          expiration_date: 5.days.ago.beginning_of_minute)
        FactoryBot.create(:legacy_local_charge,
          organization: organization,
          direction: "export",
          tenant_vehicle_id: default_tenant_vehicle.id,
          hub: origin_hub,
          effective_date: DateTime.now.beginning_of_minute,
          expiration_date: 10.days.from_now.beginning_of_minute)
      end

      it "returns the expected result for one tenant vehicle chain with invalid Local Charges and no Trips",
        :aggregate_failures do
        expect(target_result.dig(:origin_local_charges)).to eq(required: false, status: "no_data", last_expiry: nil)
        expect(target_result.dig(:destination_local_charges)).to eq(required: false, status: "no_data",
                                                                    last_expiry: nil)
        expect(target_result.dig(:freight)).to eq(required: true, status: "expired", last_expiry: nil)
        expect(target_result.dig(:schedules)).to eq(required: true, status: "no_data", last_expiry: nil)
      end
    end

    context "with one tenant vehicle chain with invalid Local Charges and good Trips" do
      let(:tenant_vehicle_3) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
      let(:target_result) { result.first[:results].find { |res| res[:service_level] == tenant_vehicle_3.name } }
      let!(:pricing_3) do
        FactoryBot.create(:lcl_pricing,
          organization: organization,
          tenant_vehicle_id: tenant_vehicle_3.id,
          itinerary: itinerary,
          effective_date: DateTime.now.beginning_of_minute,
          expiration_date: 60.days.from_now.beginning_of_minute)
      end
      let!(:trip) do
        FactoryBot.create(:legacy_trip,
          itinerary: itinerary,
          tenant_vehicle_id: tenant_vehicle_3.id,
          load_type: "cargo_item",
          start_date: 31.days.from_now.beginning_of_minute,
          end_date: 60.days.from_now.beginning_of_minute)
      end

      it "returns the expected result for one tenant vehicle chain with invalid Local Charges and good Trips",
        :aggregate_failures do
        expect(target_result.dig(:origin_local_charges)).to eq(required: false, status: "no_data", last_expiry: nil)
        expect(target_result.dig(:destination_local_charges)).to eq(required: false, status: "no_data",
                                                                    last_expiry: nil)
        expect(target_result.dig(:freight)).to eq(required: true, status: "good",
                                                  last_expiry: pricing_3.expiration_date.beginning_of_minute)
        expect(target_result.dig(:schedules)).to eq(required: true, status: "good", last_expiry: trip.start_date)
      end
    end
  end
end
