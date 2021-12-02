# frozen_string_literal: true

require "rails_helper"

RSpec.describe Validator::Itinerary do
  describe "#perform" do
    let(:organization) { FactoryBot.create(:organizations_organization, scope: organizations_scope) }
    let(:organizations_scope) { FactoryBot.build(:organizations_scope, content: {dedicated_pricings_only: dedicated_pricings_only}) }
    let!(:user) { FactoryBot.create(:users_client, organization: organization) }
    let(:dedicated_pricings_only) { false }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
    let(:carrier_1) { FactoryBot.create(:legacy_carrier, name: "TCR") }
    let(:default_tenant_vehicle) {
      FactoryBot.create(:legacy_tenant_vehicle, organization: organization,
                                                name: "Default", carrier: carrier_1)
    }
    let(:origin_hub) { itinerary.origin_hub }
    let(:destination_hub) { itinerary.destination_hub }

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
    let(:results) { described_class.new(user: user, itinerary: itinerary).perform }
    let!(:group_1) { FactoryBot.create(:groups_group, organization: organization, name: "Test") }
    let!(:membership_1) { FactoryBot.create(:groups_membership, group: group_1, member: user) }
    let!(:pricing_3) do
      FactoryBot.create(:lcl_pricing,
        organization: organization,
        tenant_vehicle_id: default_tenant_vehicle.id,
        itinerary: itinerary,
        group_id: group_1.id,
        expiration_date: 100.days.from_now.beginning_of_minute)
    end
    let!(:origin_local_charge_2) do
      FactoryBot.create(:legacy_local_charge,
        organization: organization,
        direction: "export",
        tenant_vehicle_id: default_tenant_vehicle.id,
        hub: origin_hub,
        group_id: group_1.id,
        expiration_date: 100.days.from_now.beginning_of_minute)
    end
    let!(:destination_local_charge_2) do
      FactoryBot.create(:legacy_local_charge,
        organization: organization,
        direction: "import",
        tenant_vehicle_id: default_tenant_vehicle.id,
        hub: destination_hub,
        group_id: group_1.id,
        expiration_date: 100.days.from_now.beginning_of_minute)
    end
    let(:default_result) { results.find { |result| result.dig(:group, :name) == "default" } }
    let(:group_result) { results.find { |result| result.dig(:group, :name) == "Test" } }
    let(:target_default_result) do
      default_result[:results].find { |res| res[:service_level] == default_tenant_vehicle.name }
    end
    let(:target_group_result) do
      group_result[:results].find { |res| res[:service_level] == default_tenant_vehicle.name }
    end

    it "returns the expected result for one tenant vehicle chain", :aggregate_failures do
      expect(target_default_result.dig(:origin_local_charges)).to eq(
        required: false, status: "good", last_expiry: origin_local_charge.expiration_date.beginning_of_minute
      )
      expect(target_default_result.dig(:destination_local_charges)).to eq(
        required: false, status: "good", last_expiry: destination_local_charge.expiration_date.beginning_of_minute
      )
      expect(target_default_result.dig(:freight)).to eq(
        required: true, status: "good", last_expiry: pricing_1.expiration_date.beginning_of_minute
      )
      expect(target_default_result.dig(:schedules)).to eq(
        required: true, status: "expiring_soon", last_expiry: trip.start_date
      )
      expect(target_group_result.dig(:origin_local_charges)).to eq(
        required: false, status: "good", last_expiry: origin_local_charge_2.expiration_date.beginning_of_minute
      )
      expect(target_group_result.dig(:destination_local_charges)).to eq(
        required: false, status: "good", last_expiry: destination_local_charge_2.expiration_date.beginning_of_minute
      )
      expect(target_group_result.dig(:freight)).to eq(
        required: true, status: "good", last_expiry: pricing_3.expiration_date.beginning_of_minute
      )
      expect(target_group_result.dig(:schedules)).to eq(
        required: true, status: "expiring_soon", last_expiry: trip.start_date
      )
    end

    context "with dedicated_pricings_only" do
      let(:dedicated_pricings_only) { true }

      it "returns the expected result for one tenant vehicle chain with dedicated pricings only", :aggregate_failures do
        expect(target_default_result.dig(:origin_local_charges)).to eq(
          required: false, status: "good", last_expiry: origin_local_charge.expiration_date.beginning_of_minute
        )
        expect(target_default_result.dig(:destination_local_charges)).to eq(
          required: false, status: "good", last_expiry: destination_local_charge.expiration_date.beginning_of_minute
        )
        expect(target_default_result.dig(:freight)).to eq(
          required: true, status: "good", last_expiry: pricing_1.expiration_date.beginning_of_minute
        )
        expect(target_default_result.dig(:schedules)).to eq(
          required: true, status: "expiring_soon", last_expiry: trip.start_date
        )
        expect(target_group_result.dig(:origin_local_charges)).to eq(
          required: false, status: "good", last_expiry: origin_local_charge_2.expiration_date.beginning_of_minute
        )
        expect(target_group_result.dig(:destination_local_charges)).to eq(
          required: false, status: "good", last_expiry: destination_local_charge_2.expiration_date.beginning_of_minute
        )
        expect(target_group_result.dig(:freight)).to eq(
          required: true, status: "good", last_expiry: pricing_3.expiration_date.beginning_of_minute
        )
        expect(target_group_result.dig(:schedules)).to eq(required: true, status: "expiring_soon",
                                                          last_expiry: trip.start_date)
      end
    end

    context "with one tenant vehicle chain  with invalid Local Charges and no Trips", :aggregate_failures do
      let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
      let!(:pricing_4) do
        FactoryBot.create(:lcl_pricing,
          organization: organization,
          tenant_vehicle_id: tenant_vehicle_2.id,
          itinerary: itinerary,
          group_id: group_1.id,
          expiration_date: 10.days.from_now.beginning_of_minute)
      end
      let(:target_group_result) { group_result[:results].find { |res| res[:service_level] == tenant_vehicle_2.name } }

      it "returns the expected result ", :aggregate_failures do
        expect(target_group_result.dig(:origin_local_charges)).to eq(required: false, status: "no_data",
                                                                     last_expiry: nil)
        expect(target_group_result.dig(:destination_local_charges)).to eq(required: false, status: "no_data",
                                                                          last_expiry: nil)
        expect(target_group_result.dig(:freight)).to eq(
          required: true, status: "expiring_soon", last_expiry: pricing_4.expiration_date.beginning_of_minute
        )
        expect(target_group_result.dig(:schedules)).to eq(required: true, status: "no_data", last_expiry: nil)
      end
    end
  end
end
