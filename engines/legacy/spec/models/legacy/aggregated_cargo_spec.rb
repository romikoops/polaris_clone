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

    describe '#cargo_class' do
      it 'returns the cargo class' do
        cargo = FactoryBot.create(:legacy_aggregated_cargo)
        expect(cargo.cargo_class).to eq('lcl')
      end
    end

    describe '#set_chargeable_weight!' do
      it 'calculates the chargeableweight and set it' do
        cargo = FactoryBot.create(:legacy_aggregated_cargo)
        expect(cargo.set_chargeable_weight!).to eq(1000)
      end
    end
  end
end

# == Schema Information
#
# Table name: aggregated_cargos
#
#  id                :bigint           not null, primary key
#  chargeable_weight :decimal(, )
#  volume            :decimal(, )
#  weight            :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sandbox_id        :uuid
#  shipment_id       :integer
#
# Indexes
#
#  index_aggregated_cargos_on_sandbox_id  (sandbox_id)
#
