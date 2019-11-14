# frozen_string_literal: true

require 'rails_helper'

module Shipments
  RSpec.describe Unit, type: :model do
    describe 'cargo unit functionality' do
      it_behaves_like 'a Cargo Unit' do
        subject do
          unit = FactoryBot.build(:shipments_unit, :lcl, quantity: 2,
                                                         weight_value: 3000,
                                                         width_value: 1.20,
                                                         length_value: 0.80,
                                                         height_value: 1.40,
                                                         volume_value: 1.344)
          unit.validate
          unit
        end
      end
    end

    describe 'validity' do
      let(:unit) { FactoryBot.build(:shipments_unit, :lcl, quantity: 2) }

      it 'is valid' do
        expect(unit).to be_valid
      end
    end
  end
end
