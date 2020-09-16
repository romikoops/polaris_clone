class CreateMigratorUniqueCarrierSyncs < ActiveRecord::Migration[5.2]
  def change
    create_table :migrator_unique_carrier_syncs, id: :uuid do |t|
      t.references :unique_carrier, references: :carriers, foreign_key: {to_table: :carriers}
      t.references :duplicate_carrier, references: :carriers, foreign_key: {to_table: :carriers}

      t.index %i[unique_carrier_id duplicate_carrier_id],
        name: :index_carriers_syncs_on_unique_id_and_duplicate_id, unique: true

      t.timestamps
    end
  end
end
