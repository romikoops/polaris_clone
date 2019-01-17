# frozen_string_literal: true

class CreateLocationsLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :locations_locations, id: :uuid do |t|
      t.geometry 'bounds', limit: { srid: 0, type: 'geometry' }
      t.integer :osm_id, :limit => 8
      t.string :name
      t.integer :admin_level
      t.timestamps
    end
  end
end
