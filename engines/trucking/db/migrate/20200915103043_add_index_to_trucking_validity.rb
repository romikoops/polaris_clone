class AddIndexToTruckingValidity < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :trucking_truckings, :validity, using: :gist, algorithm: :concurrently
  end
end
