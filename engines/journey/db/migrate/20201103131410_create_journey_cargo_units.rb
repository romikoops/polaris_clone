class CreateJourneyCargoUnits < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_cargo_units, id: :uuid do |t|
      t.references :query, type: :uuid, index: true, foreign_key: {on_delete: :cascade, to_table: "journey_queries"}
      t.integer :quantity, null: false, default: 1
      t.boolean :stackable, null: false
      t.string :cargo_class, null: false
      t.string :weight_unit, default: "kg", null: false
      t.string :width_unit, default: "m", null: false
      t.string :length_unit, default: "m", null: false
      t.string :height_unit, default: "m", null: false
      t.decimal :weight_value, default: 0.0, scale: 5, precision: 20, null: false
      t.decimal :width_value, default: 0.0, scale: 5, precision: 20, null: false
      t.decimal :length_value, default: 0.0, scale: 5, precision: 20, null: false
      t.decimal :height_value, default: 0.0, scale: 5, precision: 20, null: false
      t.timestamps
    end

    safety_assured do
      add_numericality_constraint :journey_cargo_units, :quantity, greater_than: 0
      add_presence_constraint :journey_cargo_units, :cargo_class
      add_presence_constraint :journey_cargo_units, :weight_unit
      add_presence_constraint :journey_cargo_units, :width_unit
      add_presence_constraint :journey_cargo_units, :length_unit
      add_presence_constraint :journey_cargo_units, :height_unit
      add_numericality_constraint :journey_cargo_units, :weight_value, greater_than: 0
      add_numericality_constraint :journey_cargo_units, :width_value, greater_than: 0
      add_numericality_constraint :journey_cargo_units, :length_value, greater_than: 0
      add_numericality_constraint :journey_cargo_units, :height_value, greater_than: 0
    end
  end
end
