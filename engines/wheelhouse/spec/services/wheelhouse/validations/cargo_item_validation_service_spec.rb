# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wheelhouse::Validations::CargoItemValidationService do
  before do
    FactoryBot.create(:legacy_max_dimensions_bundle, tenant: tenant, mode_of_transport: 'ocean')
  end

  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, with_profile: true) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, tenant: tenant) }
  let(:result) do
    described_class.errors(
      tenant: tenants_tenant,
      cargo: cargo,
      modes_of_transport: modes_of_transport,
      tenant_vehicle_ids: tenant_vehicle_ids,
      final: final
    )
  end
  let(:final) { false }
  let(:modes_of_transport) { ['ocean'] }
  let(:tenant_vehicle_ids) { [tenant_vehicle.id] }
  let(:cargo) { FactoryBot.build(:cargo_cargo, tenant: tenants_tenant, units: cargos) }

  describe '.perform' do
    context 'when the object is complete and valid' do
      let(:cargos) do
        [FactoryBot.build(:lcl_unit,
                          tenant: tenants_tenant,
                          id: SecureRandom.uuid,
                          quantity: 1,
                          width_value: 1.2,
                          length_value: 1.2,
                          height_value: 1.2,
                          weight_value: 120)]
      end
      let(:tenant_vehicle_ids) { nil }

      it 'returns an empty array' do
        expect(result).to be_empty
      end
    end

    context 'when the object is incomplete and valid' do
      let(:cargos) do
        [FactoryBot.build(:lcl_unit,
                          tenant: tenants_tenant,
                          id: SecureRandom.uuid,
                          quantity: 1,
                          width_value: 1.2,
                          length_value: 0,
                          height_value: 0,
                          weight_value: 0)]
      end
      let(:tenant_vehicle_ids) { nil }

      it 'returns an empty array' do
        expect(result).to be_empty
      end
    end

    context 'when the object is incomplete and valid (final)' do
      let(:cargos) do
        [FactoryBot.build(:lcl_unit,
                          tenant: tenants_tenant,
                          id: SecureRandom.uuid,
                          quantity: 0,
                          width_value: 1.2,
                          length_value: 0,
                          height_value: 0,
                          weight_value: 0)]
      end
      let(:tenant_vehicle_ids) { nil }
      let(:final) { true }
      let(:expected_help_text) do
        ['Length is required.',
         'Quantity is required.',
         'Height is required.',
         'Weight is required.']
      end
      let(:expected_error_codes) do
        [4010, 4011, 4013, 4017]
      end

      it 'returns an an array of missing values' do
        aggregate_failures do
          expect(result.map(&:message)).to match_array(expected_help_text)
          expect(result.map(&:code).uniq).to match_array(expected_error_codes)
        end
      end
    end

    context 'when the object is invalid (negative values)' do
      let(:cargos) do
        [FactoryBot.build(:lcl_unit,
                          tenant: tenants_tenant,
                          id: SecureRandom.uuid,
                          quantity: 1,
                          width_value: -1.2,
                          length_value: -1.0,
                          height_value: -1.0,
                          weight_value: -1.0)]
      end
      let(:tenant_vehicle_ids) { nil }
      let(:expected_help_text) do
        ['Length must be positive.',
         'Height must be positive.',
         'Width must be positive.',
         'Chargeable Weight must be positive.',
         'Weight must be positive.']
      end
      let(:expected_error_codes) do
        [4015]
      end

      it 'returns an an array of missing values' do
        aggregate_failures do
          expect(result.length).to eq(5)
          expect(result.map(&:message)).to match_array(expected_help_text)
          expect(result.map(&:code).uniq).to match_array(expected_error_codes)
        end
      end
    end

    context 'when the object is complete and all attrs are invalid' do
      let(:cargos) do
        [FactoryBot.build(:lcl_unit,
                          tenant: tenants_tenant,
                          id: SecureRandom.uuid,
                          quantity: 1,
                          width_value: 12,
                          length_value: 12,
                          height_value: 12,
                          weight_value: 12_000)]
      end
      let(:modes_of_transport) { ['ocean'] }
      let(:expected_help_text) do
        ['Width exceeds the limit of 5 m',
         'Length exceeds the limit of 5 m',
         'Height exceeds the limit of 5 m',
         'Weight exceeds the limit of 10000 kg',
         'Chargeable Weight exceeds the limit of 10000 kg']
      end
      let(:expected_error_codes) do
        [4001, 4002, 4003, 4004, 4005]
      end

      it 'returns an array of 5 errors' do
        aggregate_failures do
          expect(result.length).to eq(5)
          expect(result.map(&:message)).to match_array(expected_help_text)
          expect(result.map(&:code).uniq).to match_array(expected_error_codes)
        end
      end
    end

    context 'when the object is incomplete and invalid' do
      let(:cargos) do
        [FactoryBot.build(:lcl_unit,
                          tenant: tenants_tenant,
                          id: SecureRandom.uuid,
                          quantity: 1,
                          width_value: 12,
                          length_value: 0,
                          height_value: 0,
                          weight_value: 0)]
      end
      let(:modes_of_transport) { ['ocean'] }
      let(:expected_help_text) { ['Width exceeds the limit of 5 m'] }

      it 'returns an array of one error' do
        aggregate_failures do
          expect(result.length).to eq(1)
          expect(result.map(&:message)).to match_array(expected_help_text)
          expect(result.map(&:code).uniq).to match_array([4003])
        end
      end
    end

    context 'when the cargos are valid but aggregate chargeable weight invalid' do
      before do
        FactoryBot.create(:legacy_max_dimensions_bundle,
                          aggregate: true,
                          tenant: tenant,
                          mode_of_transport: 'ocean',
                          tenant_vehicle: tenant_vehicle,
                          chargeable_weight: 500)
      end

      let(:cargos) do
        [
          FactoryBot.build(:lcl_unit,
                           tenant: tenants_tenant,
                           id: SecureRandom.uuid,
                           quantity: 1,
                           width_value: 1,
                           length_value: 1,
                           height_value: 1,
                           weight_value: 120),
          FactoryBot.build(:lcl_unit,
                           tenant: tenants_tenant,
                           id: SecureRandom.uuid,
                           quantity: 1,
                           width_value: 1,
                           length_value: 1,
                           height_value: 1,
                           weight_value: 400)
        ]
      end
      let(:expected_help_text) do
        [
          'Aggregate Chargeable Weight exceeds the limit of 500 kg'
        ]
      end

      it 'returns an array of errors for each input when aggregate fails validation' do
        aggregate_failures do
          expect(result.length).to eq(8)
          expect(result.map(&:message).uniq).to match_array(expected_help_text)
          expect(result.map(&:code).uniq).to match_array([4006])
        end
      end
    end

    context 'when the cargos are valid but aggregate weight invalid' do
      before do
        FactoryBot.create(:legacy_max_dimensions_bundle,
                          aggregate: true,
                          tenant: tenant,
                          mode_of_transport: 'ocean',
                          tenant_vehicle: tenant_vehicle,
                          payload_in_kg: 500)
      end

      let(:cargos) do
        [
          FactoryBot.build(:lcl_unit,
                           tenant: tenants_tenant,
                           id: SecureRandom.uuid,
                           quantity: 1,
                           width_value: 1,
                           length_value: 1,
                           height_value: 1,
                           weight_value: 1.2),
          FactoryBot.build(:lcl_unit,
                           tenant: tenants_tenant,
                           id: SecureRandom.uuid,
                           quantity: 1,
                           width_value: 1,
                           length_value: 1,
                           height_value: 1,
                           weight_value: 500)
        ]
      end
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

    context 'when the cargos are invalid for one of two mots' do
      before do
        FactoryBot.create(:legacy_max_dimensions_bundle,
                          tenant: tenant,
                          mode_of_transport: 'air',
                          tenant_vehicle: tenant_vehicle,
                          payload_in_kg: 500)
      end

      let(:modes_of_transport) { %w[air ocean] }
      let(:cargos) do
        [
          FactoryBot.build(:lcl_unit,
                           tenant: tenants_tenant,
                           id: SecureRandom.uuid,
                           quantity: 1,
                           width_value: 1,
                           length_value: 1,
                           height_value: 1,
                           weight_value: 120),
          FactoryBot.build(:lcl_unit,
                           tenant: tenants_tenant,
                           id: SecureRandom.uuid,
                           quantity: 1,
                           width_value: 1,
                           length_value: 1,
                           height_value: 1,
                           weight_value: 500)
        ]
      end

      it 'returns an array of errors for each input when aggregate fails validation' do
        aggregate_failures do
          expect(result.length).to eq(0)
        end
      end
    end
  end
end
