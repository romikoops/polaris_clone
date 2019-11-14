# frozen_string_literal: true

require 'rails_helper'

module Shipments
  RSpec.describe Cargo, type: :model do
    describe 'cargo functionality' do
      it_behaves_like 'aggregated cargo' do
        subject do
          cargo = FactoryBot.build(:shipments_cargo, units: [
                                     FactoryBot.build(:shipment_aggregated_unit, weight_value: 3000, volume_value: 1.3, height_value: 1.3)
                                   ])
          cargo.validate
          cargo
        end
      end

      it_behaves_like 'multiple lcl units' do
        subject do
          cargo = FactoryBot.build(:shipments_cargo,
                                   units:
                                     FactoryBot.build_list(:shipment_lcl_unit, 5,
                                                           weight_value: 3000,
                                                           quantity: 2,
                                                           width_value: 1.20,
                                                           length_value: 0.80,
                                                           height_value: 1.40,
                                                           volume_value: 1.344,
                                                           stackable: false))
          cargo.validate
          cargo
        end
      end
    end

    describe 'validity' do
      let(:shipment) { FactoryBot.build(:shipments_shipment) }
      let(:cargo) {
        FactoryBot.build(:shipments_cargo,
                         shipment: shipment,
                         units: FactoryBot.build_list(:shipment_lcl_unit, 4))
      }

      it 'is valid' do
        expect(cargo).to be_valid
      end
    end
  end
end
