class CreateMigratorUniqueTruckingSyncs < ActiveRecord::Migration[5.2]
  def change
    create_table :migrator_unique_trucking_syncs, id: :uuid do |t|
      t.references :unique_trucking, type: :uuid,
                                     references: :trucking_truckings,
                                     foreign_key: {to_table: :trucking_truckings},
                                     index: {name: "index_truckings_syncs_on_unique_trucking_id"}
      t.references :duplicate_trucking, type: :uuid,
                                        references: :trucking_truckings,
                                        foreign_key: {to_table: :trucking_truckings},
                                        index: {
                                          unique: true,
                                          name: "index_truckings_syncs_on_duplicate_trucking_id"
                                        }

      t.index %i[unique_trucking_id duplicate_trucking_id],
        unique: true,
        name: :index_truckings_syncs_on_unique_id_and_duplicate_id

      t.timestamps
    end
  end
end
