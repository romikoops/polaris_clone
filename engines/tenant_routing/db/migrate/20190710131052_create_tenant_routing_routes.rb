class CreateTenantRoutingRoutes < ActiveRecord::Migration[5.2]
  def change
    create_table :tenant_routing_routes, id: :uuid do |t|
      t.uuid :tenant_id
      t.uuid :route_id
      t.integer :mode_of_transport, default: 0, index: true
      t.integer :price_factor
      t.integer :time_factor
      t.uuid :line_service_id, index: true
      t.timestamps
    end
  end
end
