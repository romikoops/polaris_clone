# frozen_string_literal: true

class CreateLedgerRoutings < ActiveRecord::Migration[5.2]
  def change
    create_table :ledger_routings, id: :uuid do |t|
      t.references :origin_location, type: :uuid, index: true, null: false
      t.references :destination_location, type: :uuid, index: true, null: false

      t.timestamps
    end
  end
end
