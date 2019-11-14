# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe TransportCategory, type: :model do
    describe 'factories' do
      it 'returns the cargo_item and ocean mot' do
        transport_category = FactoryBot.create(:ocean_lcl)
        expect(transport_category.cargo_class).to eq('lcl')
        expect(transport_category.mode_of_transport).to eq('ocean')
      end

      it 'returns the fcl_20 and ocean mot' do
        transport_category = FactoryBot.create(:ocean_fcl_20)
        expect(transport_category.cargo_class).to eq('fcl_20')
        expect(transport_category.mode_of_transport).to eq('ocean')
      end

      it 'returns the fcl_40 and ocean mot' do
        transport_category = FactoryBot.create(:ocean_fcl_40)
        expect(transport_category.cargo_class).to eq('fcl_40')
        expect(transport_category.mode_of_transport).to eq('ocean')
      end

      it 'returns the fcl_40_hq and ocean mot' do
        transport_category = FactoryBot.create(:ocean_fcl_40_hq)
        expect(transport_category.cargo_class).to eq('fcl_40_hq')
        expect(transport_category.mode_of_transport).to eq('ocean')
      end
    end
  end
end
