# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe MaxDimensionsBundle, type: :model do
    let(:tenant) { FactoryBot.create(:legacy_tenant) }
    let(:empty_tenant) { FactoryBot.create(:legacy_tenant, no_max_dimensions: true) }

    describe 'mode_of_transport uniqueness' do
      let(:max_dimensions_bundle_attributes) { FactoryBot.attributes_for(:legacy_max_dimensions_bundle, tenant_id: tenant.id, aggregate: true) }

      it 'return error' do
        expect { described_class.new(max_dimensions_bundle_attributes).save! }.to raise_exception(ActiveRecord::RecordInvalid)
      end
    end

    describe '.to_max_dimensions_hash' do
      before do
        FactoryBot.create(:legacy_max_dimensions_bundle, tenant_id: empty_tenant.id, aggregate: true)
      end

      it 'return all max dimensions' do
        expect(described_class.to_max_dimensions_hash).to eq(general: { chargeable_weight: 0.1e5, dimension_x: 0.5e3, dimension_y: 0.5e3, dimension_z: 0.5e3, payload_in_kg: 0.1e5 })
      end
    end

    describe '.create_defaults_for' do
      it 'create the default values for tenant' do
        described_class.create_defaults_for(empty_tenant)

        expect(empty_tenant.max_dimensions_bundles.pluck(:mode_of_transport)).to match_array %w[general air]
      end

      it 'create the default aggregate values for tenant' do
        described_class.create_defaults_for(empty_tenant, aggregate: true)

        expect(empty_tenant.max_dimensions_bundles.pluck(:mode_of_transport)).to match_array %w[general air]
      end

      it 'ignores the modes of transport acording to modes_of_transport param' do
        described_class.create_defaults_for(empty_tenant, modes_of_transport: 'ocean')
        expect(empty_tenant.max_dimensions_bundles).to be_empty
      end

      it 'creates defaults for all' do
        described_class.create_defaults_for(empty_tenant, all: true)

        bundles = empty_tenant.max_dimensions_bundles.where(aggregate: false)
        aggregated_bundles = empty_tenant.max_dimensions_bundles.where(aggregate: true)

        expect(bundles.pluck(:mode_of_transport)).to match_array %w[general air]
        expect(aggregated_bundles.pluck(:mode_of_transport)).to match_array %w[general air]
      end
    end

    describe '.creates a valid object' do
      let!(:max_dimensions_bundle) { FactoryBot.build(:legacy_max_dimensions_bundle) }

      it 'builds a valid max dimensions bundle' do
        expect(max_dimensions_bundle).to be_valid
      end
    end
  end
end

# == Schema Information
#
# Table name: max_dimensions_bundles
#
#  id                :bigint           not null, primary key
#  aggregate         :boolean
#  chargeable_weight :decimal(, )
#  dimension_x       :decimal(, )
#  dimension_y       :decimal(, )
#  dimension_z       :decimal(, )
#  mode_of_transport :string
#  payload_in_kg     :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  carrier_id        :bigint
#  sandbox_id        :uuid
#  tenant_id         :integer
#  tenant_vehicle_id :bigint
#
# Indexes
#
#  index_max_dimensions_bundles_on_carrier_id         (carrier_id)
#  index_max_dimensions_bundles_on_mode_of_transport  (mode_of_transport)
#  index_max_dimensions_bundles_on_sandbox_id         (sandbox_id)
#  index_max_dimensions_bundles_on_tenant_id          (tenant_id)
#  index_max_dimensions_bundles_on_tenant_vehicle_id  (tenant_vehicle_id)
#
