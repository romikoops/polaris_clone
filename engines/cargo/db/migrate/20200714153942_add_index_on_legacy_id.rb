class AddIndexOnLegacyId < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :cargo_units, :legacy_id, algorithm: :concurrently
  end
end
