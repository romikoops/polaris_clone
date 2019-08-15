# frozen_string_literal: true

class AddMotToRoutingConnections < ActiveRecord::Migration[5.2]
  def up
    add_column :tenant_routing_connections, :mode_of_transport, :integer, index: true
    change_column_default :tenant_routing_connections, :mode_of_transport, 0
    add_column :tenant_routing_connections, :line_service_id, :uuid, index: true
  end

  def down
    remove_column :tenant_routing_connections, :mode_of_transport
  end
end
