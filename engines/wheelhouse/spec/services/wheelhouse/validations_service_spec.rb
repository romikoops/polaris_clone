# frozen_string_literal: true

require 'rails_helper'

module Wheelhouse
  RSpec.describe ValidationService, type: :service do
    let(:tenant) { FactoryBot.create(:legacy_tenant) }
    let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
    let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, tokens: {}, with_profile: true) }
    let(:tenants_user) { Tenants::User.find_by(legacy: user) }
    let(:origin_nexus) { FactoryBot.create(:legacy_nexus, tenant: tenant) }
    let(:destination_nexus) { FactoryBot.create(:legacy_nexus, tenant: tenant) }
    let(:origin_hub) { itinerary.origin_hub }
    let(:destination_hub) { itinerary.destination_hub }
    let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly') }
    let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: 'quickly') }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
    let(:cargo) { FactoryBot.build(:cargo_cargo, tenant: tenants_tenant, units: cargos) }
    let(:cargos) do
      [
        FactoryBot.build(:lcl_unit,
                         id: SecureRandom.uuid,
                         weight_value: 120,
                         width_value: 1.20,
                         length_value: 0.80,
                         height_value: 1.20,
                         quantity: 1)
      ]
    end
    let(:origin) { { nexus_id: origin_hub.nexus_id } }
    let(:destination) { { nexus_id: destination_hub.nexus_id } }
    let(:routing) { { origin: origin, destination: destination } }
    let(:load_type) { 'cargo_item' }
    let(:final) { false }
    let(:validator) do
      described_class.new(user: tenants_user, routing: routing, cargo: cargo, load_type: load_type, final: final)
    end
    let(:result) do
      validator.validate
      validator.errors
    end

    describe '.perform' do
      context 'when port to port complete request (no pricings)' do
        let(:expected_error_codes) do
          [4008]
        end

        it 'returns an array of one error' do
          aggregate_failures do
            expect(result.map(&:code)).to match_array(expected_error_codes)
          end
        end
      end

      context 'when port to port (no routing)' do
        let(:expected_error_codes) do
          [4016]
        end
        let(:routing) { { origin: nil, destination: nil } }
        let(:final) { true }

        it 'returns an array of one error' do
          aggregate_failures do
            expect(result.map(&:code)).to match_array(expected_error_codes)
          end
        end
      end

      context 'when port to port complete request (no group pricings)' do
        let(:expected_error_codes) do
          [4009]
        end

        before do
          FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { dedicated_pricings_only: true })
        end

        it 'returns an array of one error' do
          aggregate_failures do
            expect(result.map(&:code)).to match_array(expected_error_codes)
          end
        end
      end

      context 'when port to port complete request (invalid cargo)' do
        let(:cargos) do
          [
            FactoryBot.build(:lcl_unit,
                             id: SecureRandom.uuid,
                             weight_value: 120,
                             width_value: 1.20,
                             length_value: 0.80,
                             height_value: 120.0,
                             quantity: 1)
          ]
        end
        let(:expected_error_codes) do
          [4002, 4005]
        end

        before do
          FactoryBot.create(:lcl_pricing, tenant: tenant, itinerary: itinerary)
        end

        it 'returns an array of one error' do
          aggregate_failures do
            expect(result.map(&:code)).to match_array(expected_error_codes)
          end
        end
      end

      context 'when port to port complete request (invalid fcl cargo)' do
        let(:cargos) do
          [
            FactoryBot.build(:fcl_20_unit,
                             id: SecureRandom.uuid,
                             weight_value: 999_999,
                             quantity: 1)
          ]
        end
        let(:load_type) { 'container' }
        let(:expected_error_codes) do
          [4001]
        end

        before do
          FactoryBot.create(:legacy_max_dimensions_bundle, cargo_class: 'fcl_20', tenant: tenant, payload_in_kg: 30_000)
          FactoryBot.create(:lcl_pricing, tenant: tenant, itinerary: itinerary)
        end

        it 'returns an array of one error' do
          aggregate_failures do
            expect(result.map(&:code)).to match_array(expected_error_codes)
          end
        end
      end
    end
  end
end
