# frozen_string_literal: true

module TenantRouting
  class Connection < ApplicationRecord
    belongs_to :inbound, class_name: 'TenantRouting::Route'
    belongs_to :outbound, class_name: 'TenantRouting::Route'
  end
end

# == Schema Information
#
# Table name: tenant_routing_connections
#
#  id          :uuid             not null, primary key
#  inbound_id  :uuid
#  outbound_id :uuid
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
