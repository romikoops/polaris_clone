class CreateJourneyErrors < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_errors, id: :uuid do |t|
      t.references :result_set, type: :uuid, index: true,
                                foreign_key: {on_delete: :cascade, to_table: "journey_result_sets"}
      t.references :cargo_unit, type: :uuid, index: true,
                                foreign_key: {on_delete: :cascade, to_table: "journey_cargo_units"}
      t.integer :code
      t.string :service
      t.string :carrier
      t.string :mode_of_transport
      t.string :property
      t.string :value
      t.string :limit
      t.timestamps
    end
  end
end
