FactoryBot.define do
  factory :tenant_routing_connection, class: 'TenantRouting::Connection' do
    association :inbound, factory: :routing_route_line_service
    association :outbound, factory: :routing_route_line_service
    association :tenant, factory: :tenants_tenant
  end
end

# == Schema Information
#
# Table name: tenant_routing_connections
#
#  id                :uuid             not null, primary key
#  mode_of_transport :integer          default(0)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  inbound_id        :uuid
#  line_service_id   :uuid
#  outbound_id       :uuid
#  tenant_id         :uuid
#
# Indexes
#
#  index_tenant_routing_connections_on_inbound_id   (inbound_id)
#  index_tenant_routing_connections_on_outbound_id  (outbound_id)
#  index_tenant_routing_connections_on_tenant_id    (tenant_id)
#
