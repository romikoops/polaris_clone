class AdjustRoutingIndexes < ActiveRecord::Migration[5.2]
  def change
    remove_index :routing_routes, name: "routing_routes_index"
  end
end
