# frozen_string_literal: true

class AddMotToRoutingConnections < ActiveRecord::Migration[5.2]
  def change
    add_column :tenant_routing_connections, :mode_of_transport, :integer, default: 0, index: true
    add_column :tenant_routing_connections, :line_service_id, :uuid, index: true
  end
end
