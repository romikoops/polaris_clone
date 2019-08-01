# frozen_string_literal: true

class CreateRoutingRoutes < ActiveRecord::Migration[5.2]
  def change
    create_table :routing_routes, id: :uuid do |t|
      t.uuid :origin_id
      t.uuid :destination_id
      t.integer :allowed_cargo, default: 0, null: false
      t.integer :mode_of_transport, default: 0, null: false
      t.decimal :price_factor
      t.decimal :time_factor
      t.timestamps
    end
  end
end
