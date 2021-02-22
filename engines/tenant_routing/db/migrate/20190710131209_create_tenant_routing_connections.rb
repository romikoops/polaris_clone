# frozen_string_literal: true
class CreateTenantRoutingConnections < ActiveRecord::Migration[5.2]
  def change
    create_table :tenant_routing_connections, id: :uuid do |t|
      t.uuid :inbound_id, index: true
      t.uuid :outbound_id, index: true
      t.timestamps
    end
  end
end
