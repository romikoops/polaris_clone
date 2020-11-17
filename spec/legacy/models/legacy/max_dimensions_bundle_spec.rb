# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe MaxDimensionsBundle, type: :model do
    let(:organization) { FactoryBot.create(:organizations_organization) }

    describe 'mode_of_transport uniqueness' do
      let(:max_dimensions_bundle_attributes) { FactoryBot.attributes_for(:legacy_max_dimensions_bundle, organization_id: organization.id, aggregate: true) }

      before do
        FactoryBot.create(:legacy_max_dimensions_bundle, organization_id: organization.id, aggregate: true)
      end

      it 'return error' do
        expect { described_class.new(max_dimensions_bundle_attributes).save! }.to raise_exception(ActiveRecord::RecordInvalid)
      end
    end

    describe '.to_max_dimensions_hash' do
      before do
        FactoryBot.create(:legacy_max_dimensions_bundle, organization_id: organization.id, aggregate: true)
      end

      it 'return all max dimensions' do
        expect(described_class.to_max_dimensions_hash).to eq(general: {
          chargeable_weight: 0.1e5,
          width: 0.5e3,
          length: 0.5e3,
          height: 0.5e3,
          payload_in_kg: 0.1e5,
          volume: 0.1e5
        })
      end
    end

    describe '.creates a valid object' do
      let!(:max_dimensions_bundle) { FactoryBot.build(:legacy_max_dimensions_bundle, mode_of_transport: 'air') }

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
#  cargo_class       :string
#  chargeable_weight :decimal(, )
#  dimension_x       :decimal(, )
#  dimension_y       :decimal(, )
#  dimension_z       :decimal(, )
#  mode_of_transport :string
#  payload_in_kg     :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  carrier_id        :bigint
#  organization_id   :uuid
#  itinerary_id      :bigint
#  sandbox_id        :uuid
#  tenant_id         :integer
#  tenant_vehicle_id :bigint
#
# Indexes
#
#  index_max_dimensions_bundles_on_cargo_class        (cargo_class)
#  index_max_dimensions_bundles_on_carrier_id         (carrier_id)
#  index_max_dimensions_bundles_on_mode_of_transport  (mode_of_transport)
#  index_max_dimensions_bundles_on_organization_id    (organization_id)
#  index_max_dimensions_bundles_on_sandbox_id         (sandbox_id)
#  index_max_dimensions_bundles_on_tenant_id          (tenant_id)
#  index_max_dimensions_bundles_on_tenant_vehicle_id  (tenant_vehicle_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
