# frozen_string_literal: true

class AdjustTenantConnections < ActiveRecord::Migration[5.2]
  def change
    add_column :tenant_routing_connections, :tenant_id, :uuid, index: true
  end
end
