# frozen_string_literal: true

require 'rails_helper'
module Legacy
  RSpec.describe ChargeCategory, type: :model do
    describe '.cargo_unit' do
      let!(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
      let(:legacy_cargo_item) { FactoryBot.create(:legacy_cargo_item) }
      let(:charge_category) do
        FactoryBot.create(:legacy_charge_categories,
                          tenant: legacy_tenant,
                          code: 'cargo_item',
                          name: 'CargoItem',
                          cargo_unit_id: legacy_cargo_item.id)
      end

      it 'returns the cargo item' do
        expect(charge_category.cargo_unit).to eq(legacy_cargo_item)
      end
    end
  end
end

# == Schema Information
#
# Table name: charge_categories
#
#  id            :bigint           not null, primary key
#  code          :string
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  cargo_unit_id :integer
#  sandbox_id    :uuid
#  tenant_id     :integer
#
# Indexes
#
#  index_charge_categories_on_cargo_unit_id  (cargo_unit_id)
#  index_charge_categories_on_code           (code)
#  index_charge_categories_on_sandbox_id     (sandbox_id)
#  index_charge_categories_on_tenant_id      (tenant_id)
#
