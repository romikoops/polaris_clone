# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe TenantCargoItemType, type: :model do
    describe 'it creates a valid object' do
      it 'is valid' do
        tenant_cargo_item_type = FactoryBot.build(:legacy_tenant_cargo_item_type)
        expect(tenant_cargo_item_type).to be_valid
      end

      it 'raises  an error when item type is taken' do
        tenant = FactoryBot.create(:legacy_tenant)
        cargo_item_type = FactoryBot.create(:legacy_cargo_item_type)
        FactoryBot.create(:legacy_tenant_cargo_item_type, tenant: tenant, cargo_item_type: cargo_item_type)
        expect(FactoryBot.build(:legacy_tenant_cargo_item_type, tenant: tenant, cargo_item_type: cargo_item_type)).not_to be_valid
      end
    end
  end
end

# == Schema Information
#
# Table name: tenant_cargo_item_types
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  cargo_item_type_id :bigint
#  sandbox_id         :uuid
#  tenant_id          :bigint
#
# Indexes
#
#  index_tenant_cargo_item_types_on_cargo_item_type_id  (cargo_item_type_id)
#  index_tenant_cargo_item_types_on_sandbox_id          (sandbox_id)
#  index_tenant_cargo_item_types_on_tenant_id           (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (cargo_item_type_id => cargo_item_types.id)
#  fk_rails_...  (tenant_id => tenants.id)
#
