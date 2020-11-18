class CreateMigratorUniqueLocationsLocationsSync < ActiveRecord::Migration[5.2]
  def change
    create_table :migrator_unique_locations_locations_syncs, id: :uuid do |t|
      t.references :unique_location_location, type: :uuid, references: :location_locations,
                                              foreign_key: {to_table: :locations_locations},
                                              index: {name: "index_migrator_unique_location_location_id"}
      t.references :duplicate_location_location, type: :uuid, references: :location_locations,
                                                 foreign_key: {to_table: :locations_locations},
                                                 index: {
                                                   unique: true,
                                                   name: "index_migrator_duplicate_location_location_id"
                                                 }

      t.index %i[unique_location_location_id duplicate_location_location_id],
        unique: true,
        name: :index_location_locations_syncs_on_unique_id_and_duplicate_id

      t.timestamps
    end
  end
end
