# frozen_string_literal: true

module TenantRouting
  class Connection < ApplicationRecord
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    belongs_to :inbound, class_name: 'Routing::RouteLineService', optional: true
    belongs_to :outbound, class_name: 'Routing::RouteLineService', optional: true
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
