FactoryBot.define do
  factory :tenant_routing_route, class: 'TenantRouting::Route' do
    association :route, factory: :routing_route
    association :tenant, factory: :tenants_tenant
  end
end
