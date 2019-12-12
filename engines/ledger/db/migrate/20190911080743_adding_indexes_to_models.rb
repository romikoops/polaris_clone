# frozen_string_literal: true

class AddingIndexesToModels < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :ledger_delta, :kg_range, using: :gist, algorithm: :concurrently
    add_index :ledger_delta, :km_range, using: :gist, algorithm: :concurrently
    add_index :ledger_delta, :cbm_range, using: :gist, algorithm: :concurrently
    add_index :ledger_delta, :wm_range, using: :gist, algorithm: :concurrently
    add_index :ledger_delta, :unit_range, using: :gist, algorithm: :concurrently
    add_index :ledger_delta, :stowage_range, using: :gist, algorithm: :concurrently
    add_index :ledger_delta, :validity, using: :gist, algorithm: :concurrently
  end
end
