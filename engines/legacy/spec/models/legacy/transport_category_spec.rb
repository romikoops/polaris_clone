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

      describe '#humanize' do
        it 'return the humanized transport category' do
          transport_category = FactoryBot.create(:ocean_fcl_40_hq)
          expect(transport_category.humanize).to eq('FCL – 40 – HQ any container')
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: transport_categories
#
#  id                :bigint           not null, primary key
#  cargo_class       :string
#  load_type         :string
#  mode_of_transport :string
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sandbox_id        :uuid
#  vehicle_id        :integer
#
# Indexes
#
#  index_transport_categories_on_sandbox_id  (sandbox_id)
#
