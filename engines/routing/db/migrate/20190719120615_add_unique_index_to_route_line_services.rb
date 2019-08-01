class AddUniqueIndexToRouteLineServices < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :routing_line_services, [:carrier_id, :name], unique: true, algorithm: :concurrently, name: 'line_service_unique_index'
    add_index :routing_route_line_services, [:route_id, :line_service_id], unique: true, algorithm: :concurrently, name: 'route_line_service_index'
    add_index :routing_routes, %i(origin_id destination_id mode_of_transport), algorithm: :concurrently, unique: true, name: 'routing_routes_index'
  end
end
