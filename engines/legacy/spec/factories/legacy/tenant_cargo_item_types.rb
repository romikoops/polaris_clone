# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_tenant_cargo_item_type, class: 'Legacy::TenantCargoItemType' do
    association :tenant, factory: :legacy_tenant
    association :cargo_item_type, factory: :legacy_cargo_item_type
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
