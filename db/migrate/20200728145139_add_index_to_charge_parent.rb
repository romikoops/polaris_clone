class AddIndexToChargeParent < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :charges, :parent_id, algorithm: :concurrently
  end
end
