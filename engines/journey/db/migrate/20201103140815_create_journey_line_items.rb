class CreateJourneyLineItems < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_line_items, id: :uuid do |t|
      t.references :route_section, type: :uuid, index: true,
                                   foreign_key: {on_delete: :cascade, to_table: "journey_route_sections"}
      t.references :route_point, type: :uuid, index: true,
                                 foreign_key: {on_delete: :cascade, to_table: "journey_route_points"}
      t.references :line_item_set, type: :uuid, index: true,
                                   foreign_key: {on_delete: :cascade, to_table: "journey_line_item_sets"}
      t.string :note, null: false, default: ""
      t.integer :order, null: false
      t.string :fee_code, null: false
      t.string :description, null: false, default: ""
      t.monetize :total, amount: {null: true, default: nil}, currency: {null: true, default: nil}
      t.monetize :unit_price, amount: {null: true, default: nil}, currency: {null: true, default: nil}
      t.integer :units, null: false
      t.boolean :included, default: false
      t.boolean :optional, default: false
      t.decimal :wm_rate, null: false
      t.timestamps
    end

    safety_assured do
      add_presence_constraint :journey_line_items, :note
      add_presence_constraint :journey_line_items, :fee_code
      add_numericality_constraint :journey_line_items, :units, greater_than: 0
      add_numericality_constraint :journey_line_items, :wm_rate, greater_than: 0

      add_exclusion_constraint :journey_line_items,
        [[:line_item_set_id, "="], [:route_section_id, "="], [:route_point_id, "="], [:fee_code, "="]],
        using: :gist
    end
  end
end
