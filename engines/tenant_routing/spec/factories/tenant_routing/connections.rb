FactoryBot.define do
  factory :tenant_routing_connection, class: 'TenantRouting::Connection' do
    association :inbound, factory: :tenant_routing_route
    association :outbound, factory: :tenant_routing_route
  end
end
