class AddIndexToHubAvailabilitiesDeletedAt < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :trucking_hub_availabilities, :deleted_at, algorithm: :concurrently
  end
end
