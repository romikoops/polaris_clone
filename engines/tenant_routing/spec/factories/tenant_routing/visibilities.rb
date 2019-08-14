FactoryBot.define do
  factory :tenant_routing_visibility, class: 'TenantRouting::Visibility' do
    association :connection, factory: :tenant_routing_connection
  end
end
