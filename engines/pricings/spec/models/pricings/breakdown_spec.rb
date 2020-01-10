require 'rails_helper'

module Pricings
  RSpec.describe Breakdown, type: :model do
    describe '#code' do
      let(:charge_category) { FactoryBot.create(:legacy_charge_categories) }
      let(:target) { FactoryBot.build(:pricings_breakdown, charge_category_id: charge_category.id) }

      it 'fetch the code from Legacy::ChargeCategory' do
        expect(target.code).to eq(charge_category.code)
      end
    end

    describe '#target_name' do
      let(:metadata) { FactoryBot.create(:pricings_metadatum) }
      let(:target) { FactoryBot.build(:pricings_breakdown, target: metadata) }

      it 'fetch the name from target' do
        expect(target.target_name).to eq(nil)
      end
    end

  end
end
