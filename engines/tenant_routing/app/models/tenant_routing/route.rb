# frozen_string_literal: true

module TenantRouting
  class Route < ApplicationRecord
    belongs_to :route, class_name: 'Routing::Route'
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    enum mode_of_transport: { ocean: 1, air: 2, rail: 3, truck: 4 }
  end
end

# == Schema Information
#
# Table name: tenant_routing_routes
#
#  id                :uuid             not null, primary key
#  tenant_id         :uuid
#  route_id          :uuid
#  mode_of_transport :integer          default(NULL)
#  price_factor      :integer
#  time_factor       :integer
#  line_service_id   :uuid
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
