# frozen_string_literal: true
class CreateJourneyCommodityInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_commodity_infos, id: :uuid do |t|
      t.references :cargo_unit, type: :uuid, index: true,
                                foreign_key: {on_delete: :cascade, to_table: "journey_cargo_units"}
      t.string :hs_code
      t.string :imo_class, null: false, default: ""
      t.string :description, null: false, default: ""
      t.timestamps
    end

    safety_assured do
      add_presence_constraint :journey_commodity_infos, :description
    end
  end
end
