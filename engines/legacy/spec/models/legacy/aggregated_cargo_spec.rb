# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe AggregatedCargo, type: :model do
    describe '#calc_chareable_weight' do
      it 'calcs the volume' do
        cargo = FactoryBot.create(:legacy_aggregated_cargo)
        expect(cargo.calc_chargeable_weight('ocean')).to eq(1000)
      end
    end

    describe '#set_chargeable_weight!' do
      it 'calculates the chargeableweight and set it' do
        cargo = FactoryBot.create(:legacy_aggregated_cargo)
        expect(cargo.set_chargeable_weight!).to eq(1000)
      end
    end

    describe '#valid_for_mode_of_transport?' do
      it 'validates the mode of transport acorging to the max dimensions' do
        cargo = FactoryBot.create(:legacy_aggregated_cargo)
        expect(cargo.valid_for_mode_of_transport?('ocean')).to eq(true)
      end
    end

    describe '#describe #valid_for_mode_of_transport?' do
      let(:tenant) { Legacy::Tenant.find(cargo_item.shipment.tenant_id) }
      let(:cargo_item) { FactoryBot.create(:legacy_aggregated_cargo) }

      context 'when valid' do
        it 'returns true when cargo item is valid' do
          valid = cargo_item.valid_for_mode_of_transport?('ocean')
          expect(valid).to be_truthy
        end
      end

      context 'when invalid' do
        before do
          FactoryBot.create(:legacy_max_dimensions_bundle,
                            tenant_id: tenant.id,
                            mode_of_transport: 'air',
                            payload_in_kg: 100,
                            aggregate: true)
        end

        it 'returns false when cargo item is invalid' do
          valid = cargo_item.valid_for_mode_of_transport?('air')
          expect(valid).to be_falsy
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: cargo_items
#
#  id                 :bigint           not null, primary key
#  cargo_class        :string
#  chargeable_weight  :decimal(, )
#  customs_text       :string
#  dangerous_goods    :boolean
#  dimension_x        :decimal(, )
#  dimension_y        :decimal(, )
#  dimension_z        :decimal(, )
#  hs_codes           :string           default([]), is an Array
#  payload_in_kg      :decimal(, )
#  quantity           :integer
#  stackable          :boolean          default(TRUE)
#  unit_price         :jsonb
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  cargo_item_type_id :integer
#  sandbox_id         :uuid
#  shipment_id        :integer
#
# Indexes
#
#  index_cargo_items_on_sandbox_id  (sandbox_id)
#
