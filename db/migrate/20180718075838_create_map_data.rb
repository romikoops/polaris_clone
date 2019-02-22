# frozen_string_literal: true

class CreateMapData < ActiveRecord::Migration[5.1]
  def change
    create_table :map_data do |t|
      t.jsonb :line
      t.jsonb :geo_json
      t.decimal :origin, array: true, default: []
      t.decimal :destination, array: true, default: []
      t.string :itinerary_id
      t.integer :tenant_id
      t.timestamps
    end
  end
end
