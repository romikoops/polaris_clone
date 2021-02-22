# frozen_string_literal: true
class CreateJourneyLineItemCargoUnits < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_line_item_cargo_units, id: :uuid do |t|
      t.references :line_item, type: :uuid, index: true,
                               foreign_key: {on_delete: :cascade, to_table: "journey_line_items"}
      t.references :cargo_unit, type: :uuid, index: true,
                                foreign_key: {on_delete: :cascade, to_table: "journey_cargo_units"}
      t.timestamps
    end
  end
end
