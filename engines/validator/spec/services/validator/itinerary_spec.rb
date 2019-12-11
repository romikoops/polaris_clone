# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Validator::Itinerary do
  describe '#perform' do
    let!(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
    let!(:legacy_user) { FactoryBot.create(:legacy_user, tenant: legacy_tenant) }
    let!(:user) { Tenants::User.find_by(legacy_id: legacy_user.id) }
    let!(:tenant) { user.tenant }

    let!(:scope) { FactoryBot.create(:tenants_scope, target: user, content: { base_pricing: true }) }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: legacy_tenant) }
    let(:carrier_1) { FactoryBot.create(:legacy_carrier, name: 'TCR') }
    let(:default_tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, tenant: legacy_tenant, name: 'Default', carrier: carrier_1) }
    let(:origin_hub) { itinerary.hubs.first }
    let(:destination_hub) { itinerary.hubs.last }

    context 'generating the validity result' do
      let!(:pricing_1) do
        FactoryBot.create(:lcl_pricing,
                          tenant: legacy_tenant,
                          tenant_vehicle_id: default_tenant_vehicle.id,
                          itinerary: itinerary,
                          effective_date: DateTime.now.beginning_of_minute,
                          expiration_date: 90.days.from_now.beginning_of_minute)
      end
      let!(:origin_local_charge) do
        FactoryBot.create(:legacy_local_charge,
                          tenant: legacy_tenant,
                          direction: 'export',
                          tenant_vehicle_id: default_tenant_vehicle.id,
                          hub: origin_hub,
                          effective_date: DateTime.now.beginning_of_minute,
                          expiration_date: 90.days.from_now.beginning_of_minute)
      end
      let!(:destination_local_charge) do
        FactoryBot.create(:legacy_local_charge,
                          tenant: legacy_tenant,
                          direction: 'import',
                          tenant_vehicle_id: default_tenant_vehicle.id,
                          hub: destination_hub,
                          effective_date: DateTime.now.beginning_of_minute,
                          expiration_date: 90.days.from_now.beginning_of_minute)
      end
      let!(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle_id: default_tenant_vehicle.id, load_type: 'cargo_item') }

      describe 'without groups' do
        it 'returns the expected result for one tenant vehicle chain' do
          result = described_class.new(user: user, itinerary: itinerary).perform
          target_result = result.first[:results].find { |res| res[:service_level] == default_tenant_vehicle.name }

          expect(target_result.dig(:origin_local_charges)).to eq(required: false, status: 'good', last_expiry: origin_local_charge.expiration_date.beginning_of_minute)
          expect(target_result.dig(:destination_local_charges)).to eq(required: false, status: 'good', last_expiry: destination_local_charge.expiration_date.beginning_of_minute)
          expect(target_result.dig(:freight)).to eq(required: true, status: 'good', last_expiry: pricing_1.expiration_date.beginning_of_minute)
          expect(target_result.dig(:schedules)).to eq(required: true, status: 'expiring_soon', last_expiry: trip.start_date)
        end

        it 'returns the expected result for one tenant vehicle chain with invalid Local Charges and no Trips' do
          tenant_vehicle_2 = FactoryBot.create(:legacy_tenant_vehicle, tenant: legacy_tenant)
          pricing_2 = FactoryBot.create(:lcl_pricing,
                                        tenant: legacy_tenant,
                                        tenant_vehicle_id: tenant_vehicle_2.id,
                                        itinerary: itinerary,
                                        effective_date: 20.days.ago.beginning_of_minute,
                                        expiration_date: 5.days.ago.beginning_of_minute)
          local_charge_2 = FactoryBot.create(:legacy_local_charge,
                              tenant: legacy_tenant,
                              direction: 'export',
                              tenant_vehicle_id: default_tenant_vehicle.id,
                              hub: origin_hub,
                              effective_date: DateTime.now.beginning_of_minute,
                              expiration_date: 10.days.from_now.beginning_of_minute)
          result = described_class.new(user: user, itinerary: itinerary).perform
          target_result = result.first[:results].find { |res| res[:service_level] == tenant_vehicle_2.name }

          expect(target_result.dig(:origin_local_charges)).to eq(required: false, status: 'no_data', last_expiry: nil)
          expect(target_result.dig(:destination_local_charges)).to eq(required: false, status: 'no_data', last_expiry: nil)
          expect(target_result.dig(:freight)).to eq(required: true, status: 'expired', last_expiry: nil)
          expect(target_result.dig(:schedules)).to eq(required: true, status: 'no_data', last_expiry: nil)
        end
        it 'returns the expected result for one tenant vehicle chain with invalid Local Charges and good Trips' do
          tenant_vehicle_3 = FactoryBot.create(:legacy_tenant_vehicle, tenant: legacy_tenant)
          pricing_3 = FactoryBot.create(:lcl_pricing,
                                        tenant: legacy_tenant,
                                        tenant_vehicle_id: tenant_vehicle_3.id,
                                        itinerary: itinerary,
                                        effective_date: DateTime.now.beginning_of_minute,
                                        expiration_date: 60.days.from_now.beginning_of_minute)
          trip = FactoryBot.create(:legacy_trip,
            itinerary: itinerary,
            tenant_vehicle_id: tenant_vehicle_3.id,
            load_type: 'cargo_item',
            start_date: 30.days.from_now.beginning_of_minute,
            end_date: 60.days.from_now.beginning_of_minute
          )
          result = described_class.new(user: user, itinerary: itinerary).perform
          target_result = result.first[:results].find { |res| res[:service_level] == tenant_vehicle_3.name }

          expect(target_result.dig(:origin_local_charges)).to eq(required: false, status: 'no_data', last_expiry: nil)
          expect(target_result.dig(:destination_local_charges)).to eq(required: false, status: 'no_data', last_expiry: nil)
          expect(target_result.dig(:freight)).to eq(required: true, status: 'good', last_expiry: pricing_3.expiration_date.beginning_of_minute)
          expect(target_result.dig(:schedules)).to eq(required: true, status: 'good', last_expiry: trip.start_date)
        end
      end

      describe 'with groups' do
        let!(:group_1) { FactoryBot.create(:tenants_group, tenant: tenant, name: 'Test') }
        let!(:membership_1) { FactoryBot.create(:tenants_membership, group: group_1, member: user) }
        let!(:pricing_3) do
          FactoryBot.create(:lcl_pricing,
                            tenant: legacy_tenant,
                            tenant_vehicle_id: default_tenant_vehicle.id,
                            itinerary: itinerary,
                            group_id: group_1.id,
                            expiration_date: 100.days.from_now.beginning_of_minute)
        end
        let!(:origin_local_charge_2) do
          FactoryBot.create(:legacy_local_charge,
                            tenant: legacy_tenant,
                            direction: 'export',
                            tenant_vehicle_id: default_tenant_vehicle.id,
                            hub: origin_hub,
                            group_id: group_1.id,
                            expiration_date: 100.days.from_now.beginning_of_minute)
        end
        let!(:destination_local_charge_2) do
          FactoryBot.create(:legacy_local_charge,
                            tenant: legacy_tenant,
                            direction: 'import',
                            tenant_vehicle_id: default_tenant_vehicle.id,
                            hub: destination_hub,
                            group_id: group_1.id,
                            expiration_date: 100.days.from_now.beginning_of_minute)
        end

        it 'returns the expected result for one tenant vehicle chain' do
          results = described_class.new(user: user, itinerary: itinerary).perform
          default_result = results.find { |result| result.dig(:group, :name) == 'Default' }
          group_result = results.find { |result| result.dig(:group, :name) == 'Test' }
          target_default_result = default_result[:results].find { |res| res[:service_level] == default_tenant_vehicle.name }
          target_group_result = group_result[:results].find { |res| res[:service_level] == default_tenant_vehicle.name }

          expect(target_default_result.dig(:origin_local_charges)).to eq(required: false, status: 'good', last_expiry: origin_local_charge.expiration_date.beginning_of_minute)
          expect(target_default_result.dig(:destination_local_charges)).to eq(required: false, status: 'good', last_expiry: destination_local_charge.expiration_date.beginning_of_minute)
          expect(target_default_result.dig(:freight)).to eq(required: true, status: 'good', last_expiry: pricing_1.expiration_date.beginning_of_minute)
          expect(target_default_result.dig(:schedules)).to eq(required: true, status: 'expiring_soon', last_expiry: trip.start_date)
          expect(target_group_result.dig(:origin_local_charges)).to eq(required: false, status: 'good', last_expiry: origin_local_charge_2.expiration_date.beginning_of_minute)
          expect(target_group_result.dig(:destination_local_charges)).to eq(required: false, status: 'good', last_expiry: destination_local_charge_2.expiration_date.beginning_of_minute)
          expect(target_group_result.dig(:freight)).to eq(required: true, status: 'good', last_expiry: pricing_3.expiration_date.beginning_of_minute)
          expect(target_group_result.dig(:schedules)).to eq(required: true, status: 'expiring_soon', last_expiry: trip.start_date)
        end

        it 'returns the expected result for one tenant vehicle chain with dedicated pricings only' do
          scope.content['dedicated_pricings_only'] = true
          scope.save
          results = described_class.new(user: user, itinerary: itinerary).perform
          default_result = results.find { |result| result.dig(:group, :name) == 'Default' }
          group_result = results.find { |result| result.dig(:group, :name) == 'Test' }
          target_default_result = default_result[:results].find { |res| res[:service_level] == default_tenant_vehicle.name }
          target_group_result = group_result[:results].find { |res| res[:service_level] == default_tenant_vehicle.name }

          expect(target_default_result.dig(:origin_local_charges)).to eq(required: false, status: 'good', last_expiry: origin_local_charge.expiration_date.beginning_of_minute)
          expect(target_default_result.dig(:destination_local_charges)).to eq(required: false, status: 'good', last_expiry: destination_local_charge.expiration_date.beginning_of_minute)
          expect(target_default_result.dig(:freight)).to eq(required: true, status: 'good', last_expiry: pricing_1.expiration_date.beginning_of_minute)
          expect(target_default_result.dig(:schedules)).to eq(required: true, status: 'expiring_soon', last_expiry: trip.start_date)
          expect(target_group_result.dig(:origin_local_charges)).to eq(required: false, status: 'good', last_expiry: origin_local_charge_2.expiration_date.beginning_of_minute)
          expect(target_group_result.dig(:destination_local_charges)).to eq(required: false, status: 'good', last_expiry: destination_local_charge_2.expiration_date.beginning_of_minute)
          expect(target_group_result.dig(:freight)).to eq(required: true, status: 'good', last_expiry: pricing_3.expiration_date.beginning_of_minute)
          expect(target_group_result.dig(:schedules)).to eq(required: true, status: 'expiring_soon', last_expiry: trip.start_date)
          scope.content['dedicated_pricings_only'] = false
          scope.save
        end

        it 'returns the expected result for one tenant vehicle chain  with invalid Local Charges and no Trips' do
          tenant_vehicle_2 = FactoryBot.create(:legacy_tenant_vehicle, tenant: legacy_tenant)
          pricing_4 = FactoryBot.create(:lcl_pricing, tenant: legacy_tenant, tenant_vehicle_id: tenant_vehicle_2.id, itinerary: itinerary, group_id: group_1.id, expiration_date: 10.days.from_now.beginning_of_minute)
          results = described_class.new(user: user, itinerary: itinerary).perform

          group_result = results.find { |result| result.dig(:group, :name) == 'Test' }
          target_group_result = group_result[:results].find { |res| res[:service_level] == tenant_vehicle_2.name }
          expect(target_group_result.dig(:origin_local_charges)).to eq(required: false, status: 'no_data', last_expiry: nil)
          expect(target_group_result.dig(:destination_local_charges)).to eq(required: false, status: 'no_data', last_expiry: nil)
          expect(target_group_result.dig(:freight)).to eq(required: true, status: 'expiring_soon', last_expiry: pricing_4.expiration_date.beginning_of_minute)
          expect(target_group_result.dig(:schedules)).to eq(required: true, status: 'no_data', last_expiry: nil)
        end
      end
    end
  end
end
