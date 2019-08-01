class CreateRoutingRouteLineServices < ActiveRecord::Migration[5.2]
  def change
    create_table :routing_route_line_services, id: :uuid do |t|
      t.uuid :route_id
      t.uuid :line_service_id
      t.timestamps
    end
  end
end
