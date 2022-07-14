# frozen_string_literal: true

class CreateLedgerLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :ledger_locations, id: :uuid do |t|
      t.string :name, index: { unique: true }
      t.multi_polygon :geodata, srid: 4326, null: false
      t.string :region
      t.string :country

      t.timestamps
    end
  end
end
