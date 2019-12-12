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
#  inbound_id        :uuid
#  outbound_id       :uuid
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  tenant_id         :uuid
#  mode_of_transport :integer          default(0)
#  line_service_id   :uuid
#
