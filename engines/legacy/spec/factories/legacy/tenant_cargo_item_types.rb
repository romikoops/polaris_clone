# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_tenant_cargo_item_type, class: 'Legacy::TenantCargoItemType' do
    association :tenant, factory: :legacy_tenant
    association :cargo_item_type, factory: :legacy_cargo_item_type
  end
end
