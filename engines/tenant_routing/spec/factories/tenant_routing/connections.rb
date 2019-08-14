FactoryBot.define do
  factory :tenant_routing_connection, class: 'TenantRouting::Connection' do
    association :inbound, factory: :routing_route
    association :outbound, factory: :routing_route
    association :tenant, factory: :tenants_tenant
  end
end
