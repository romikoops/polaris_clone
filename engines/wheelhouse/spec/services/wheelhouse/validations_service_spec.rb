# frozen_string_literal: true

require 'rails_helper'

module Wheelhouse
  RSpec.describe ValidationService, type: :service do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
    let(:itinerary) { FactoryBot.create(:default_itinerary, organization: organization) }
    let(:origin_hub) { itinerary.origin_hub }
    let(:destination_hub) { itinerary.destination_hub }
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
    let(:cargo) { FactoryBot.build(:cargo_cargo, organization: organization, units: cargos) }
    let(:origin) { { nexus_id: origin_hub.nexus_id } }
    let(:destination) { { nexus_id: destination_hub.nexus_id } }
    let(:routing) { { origin: origin, destination: destination } }
    let(:load_type) { 'cargo_item' }
    let(:final) { false }
    let(:validator) do
      described_class.new(
        organization: organization,
        user: user,
        routing: routing,
        cargo: cargo,
        load_type: load_type,
        final: final
      )
    end
    let(:result) do
      validator.validate
      validator.errors
    end

    describe '.perform' do
      before do
        FactoryBot.create(:legacy_max_dimensions_bundle, organization: organization)
        FactoryBot.create(:aggregated_max_dimensions_bundle, organization: organization)
      end

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
          FactoryBot.create(:organizations_scope, target: organization, content: { dedicated_pricings_only: true })
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
          FactoryBot.create(:lcl_pricing, organization: organization, itinerary: itinerary)
        end

        it 'returns an array of one error' do
          aggregate_failures do
            expect(result.map(&:code).uniq).to match_array(expected_error_codes)
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
        let(:expected_error_codes) { [4001] }

        before do
          FactoryBot.create(:legacy_max_dimensions_bundle,
                            cargo_class: 'fcl_20',
                            organization: organization,
                            payload_in_kg: 30_000)
          FactoryBot.create(:fcl_20_pricing, organization: organization, itinerary: itinerary)
        end

        it 'returns an array of one error' do
          aggregate_failures do
            expect(result.map(&:code)).to match_array(expected_error_codes)
          end
        end
      end

      context 'when port to port complete request (valid fcl cargo & other mot mdbs)' do
        let(:cargos) do
          [
            FactoryBot.build(:fcl_20_unit,
                             id: SecureRandom.uuid,
                             weight_value: 29_999,
                             quantity: 1)
          ]
        end
        let(:load_type) { 'container' }

        before do
          FactoryBot.create(:legacy_max_dimensions_bundle, cargo_class: 'fcl_20', organization: organization, payload_in_kg: 30_000)
          FactoryBot.create(:legacy_max_dimensions_bundle, cargo_class: 'fcl_20', mode_of_transport: 'air', organization: organization, payload_in_kg: 10_000)
          FactoryBot.create(:fcl_20_pricing, organization: organization, itinerary: itinerary)
        end

        it 'returns an array of one error' do
          aggregate_failures do
            expect(result.map(&:code)).to be_empty
          end
        end
      end

      context 'when door to port (invalid lcl on trucking)' do
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
        let(:expected_error_codes) do
          [4001]
        end

        let(:origin) { FactoryBot.create(:hamburg_address) }
        let(:routing) { { origin: {latitude: origin.latitude, longitude: origin.longitude}, destination: destination } }

        before do
          FactoryBot.create(:lcl_pricing, organization: organization, itinerary: itinerary)
          FactoryBot.create(:legacy_max_dimensions_bundle,
                            cargo_class: 'lcl',
                            organization: organization, payload_in_kg: 100,
                            mode_of_transport: 'truck_carriage')

          Geocoder::Lookup::Test.add_stub([origin.latitude, origin.longitude], [
            'address_components' => [{ 'types' => ['premise'] }],
            'address' => origin.geocoded_address,
            'city' => origin.city,
            'country' => origin.country.name,
            'country_code' => origin.country.code,
            'postal_code' => origin.zip_code
          ])
        end

        it 'returns an array of one error' do
          aggregate_failures do
            expect(result.map(&:code)).to match_array(expected_error_codes)
          end
        end
      end

      context 'when door to port (invalid fcl on trucking)' do
        let(:cargos) do
          [
            FactoryBot.build(:fcl_20_unit,
                             id: SecureRandom.uuid,
                             weight_value: 50_000,
                             quantity: 1)
          ]
        end
        let(:load_type) { 'container' }
        let(:expected_error_codes) do
          [4001]
        end

        let(:origin) { FactoryBot.create(:hamburg_address) }
        let(:destination) { { nexus_id: destination_hub.nexus_id } }
        let(:routing) { { origin: {latitude: origin.latitude, longitude: origin.longitude}, destination: destination } }

        before do
          FactoryBot.create(:legacy_max_dimensions_bundle, cargo_class: 'fcl_20',
                                                           organization: organization, payload_in_kg: 80_000)
          FactoryBot.create(:legacy_max_dimensions_bundle, cargo_class: 'fcl_20', organization: organization,
                                                           payload_in_kg: 30_000, mode_of_transport: 'truck_carriage')
          FactoryBot.create(:fcl_20_pricing, organization: organization, itinerary: itinerary)

          Geocoder::Lookup::Test.add_stub([origin.latitude, origin.longitude], [
            'address_components' => [{ 'types' => ['premise'] }],
            'address' => origin.geocoded_address,
            'city' => origin.city,
            'country' => origin.country.name,
            'country_code' => origin.country.code,
            'postal_code' => origin.zip_code
          ])
        end

        it 'returns an array of one error' do
          aggregate_failures do
            expect(result.map(&:code)).to match_array(expected_error_codes)
          end
        end
      end

      context 'when port to door (invalid aggregate on trucking)' do
        before do
          FactoryBot.create(:lcl_pricing, organization: organization, itinerary: itinerary)

          Geocoder::Lookup::Test.add_stub([origin.latitude, origin.longitude], [
            'address_components' => [{ 'types' => ['premise'] }],
            'address' => origin.geocoded_address,
            'city' => origin.city,
            'country' => origin.country.name,
            'country_code' => origin.country.code,
            'postal_code' => origin.zip_code
          ])

          FactoryBot.create(:legacy_max_dimensions_bundle,
                            aggregate: true,
                            organization: organization,
                            mode_of_transport: 'truck_carriage',
                            payload_in_kg: 500)
        end

        let(:cargos) do
          [
            FactoryBot.build(:lcl_unit,
                              organization: organization,
                              id: SecureRandom.uuid,
                              quantity: 1,
                              width_value: 1,
                              length_value: 1,
                              height_value: 1,
                              weight_value: 1.2),
            FactoryBot.build(:lcl_unit,
                              organization: organization,
                              id: SecureRandom.uuid,
                              quantity: 1,
                              width_value: 1,
                              length_value: 1,
                              height_value: 1,
                              weight_value: 500)
          ]
        end

        let(:origin) { FactoryBot.create(:hamburg_address) }
        let(:routing) { { origin: {latitude: origin.latitude, longitude: origin.longitude}, destination: destination } }

        let(:expected_help_text) do
          [
            'Aggregate Weight exceeds the limit of 500 kg'
          ]
        end

        it 'returns an array of errors for each input when aggregate fails validation' do
          aggregate_failures do
            expect(result.length).to eq(2)
            expect(result.map(&:message).uniq).to match_array(expected_help_text)
            expect(result.map(&:code).uniq).to match_array([4007])
          end
        end
      end

      context 'when door to port (valid on trucking, and on the other mots)' do
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

        let(:origin) { FactoryBot.create(:hamburg_address) }
        let(:routing) { { origin: {latitude: origin.latitude, longitude: origin.longitude}, destination: destination } }

        before do
          FactoryBot.create(:lcl_pricing, organization: organization, itinerary: itinerary)
          FactoryBot.create(:legacy_max_dimensions_bundle, cargo_class: 'lcl', organization: organization,
                                                           payload_in_kg: 150, mode_of_transport: 'truck_carriage')

          Geocoder::Lookup::Test.add_stub([origin.latitude, origin.longitude], [
            'address_components' => [{ 'types' => ['premise'] }],
            'address' => origin.geocoded_address,
            'city' => origin.city,
            'country' => origin.country.name,
            'country_code' => origin.country.code,
            'postal_code' => origin.zip_code
          ])
        end

        it 'returns no errors' do
          aggregate_failures do
            expect(result).to be_empty
          end
        end
      end
    end
  end
end
