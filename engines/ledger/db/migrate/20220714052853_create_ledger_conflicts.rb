# frozen_string_literal: true

class CreateLedgerConflicts < ActiveRecord::Migration[5.2]
  def change
    create_enum :resolution_type, %w[incoming current]

    create_table :ledger_conflicts, id: :uuid do |t|
      t.references :book, type: :uuid, index: true, null: false
      t.references :staged_rate, type: :uuid, index: true, null: false
      t.references :basis_rate, type: :uuid, index: true, null: false
      t.references :merged_rate, type: :uuid, index: true, null: true
      t.enum       :resolution, enum_type: :resolution_type

      t.timestamps
    end
  end
end
