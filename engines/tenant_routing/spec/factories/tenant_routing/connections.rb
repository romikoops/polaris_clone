FactoryBot.define do
  factory :tenant_routing_connection, class: 'TenantRouting::Connection' do
    association :inbound, factory: :routing_route_line_service
    association :outbound, factory: :routing_route_line_service
    association :tenant, factory: :tenants_tenant
  end
end
