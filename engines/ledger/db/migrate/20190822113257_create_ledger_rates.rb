# frozen_string_literal: true

class CreateLedgerRates < ActiveRecord::Migration[5.2]
  def change
    create_table :ledger_rates, id: :uuid do |t|
      t.references :target, polymorphic: true, type: :uuid, index: { name: 'ledger_rate_target_index' }
      t.uuid :location_id, index: true
      t.uuid :terminal_id, index: true
      t.uuid :tenant_id, index: true
      t.timestamps
    end
  end
end
