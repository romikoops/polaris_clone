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

# == Schema Information
#
# Table name: pricings_breakdowns
#
#  id                 :uuid             not null, primary key
#  cargo_class        :string
#  cargo_unit_type    :string
#  data               :jsonb
#  order              :integer
#  rate_origin        :jsonb
#  target_type        :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  cargo_unit_id      :bigint
#  charge_category_id :integer
#  charge_id          :integer
#  margin_id          :uuid
#  metadatum_id       :uuid             not null
#  pricing_id         :string
#  target_id          :uuid
#
# Indexes
#
#  index_pricings_breakdowns_on_cargo_unit_type_and_cargo_unit_id  (cargo_unit_type,cargo_unit_id)
#  index_pricings_breakdowns_on_charge_category_id                 (charge_category_id)
#  index_pricings_breakdowns_on_charge_id                          (charge_id)
#  index_pricings_breakdowns_on_margin_id                          (margin_id)
#  index_pricings_breakdowns_on_metadatum_id                       (metadatum_id)
#  index_pricings_breakdowns_on_target_type_and_target_id          (target_type,target_id)
#
