class CreateMigratorUniqueTruckingLocationSyncs < ActiveRecord::Migration[5.2]
  def change
    create_table :migrator_unique_trucking_location_syncs, id: :uuid do |t|
      t.references :unique_trucking_location, type: :uuid, references: :trucking_locations,
                                              foreign_key: {to_table: :trucking_locations},
                                              index: {name: "index_trucking_locations_syncs_on_unique_id"}
      t.references :duplicate_trucking_location, type: :uuid, references: :trucking_locations,
                                                 foreign_key: {to_table: :trucking_locations},
                                                 index: {
                                                   unique: true,
                                                   name: "index_trucking_locations_syncs_on_duplicate_id"
                                                 }

      t.index %i[unique_trucking_location_id duplicate_trucking_location_id],
        unique: true,
        name: :index_trucking_locations_syncs_on_unique_id_and_duplicate_id

      t.timestamps
    end
  end
end
