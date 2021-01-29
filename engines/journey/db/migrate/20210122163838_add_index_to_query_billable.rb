class AddIndexToQueryBillable < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :journey_queries, :billable, algorithm: :concurrently
  end
end
