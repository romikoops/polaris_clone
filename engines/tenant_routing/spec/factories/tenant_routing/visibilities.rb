# frozen_string_literal: true

FactoryBot.define do
  factory :tenant_routing_visibility, class: 'TenantRouting::Visibility' do
    association :target, factory: :tenants_tenant
    association :connection, factory: :tenant_routing_connection
  end
end
