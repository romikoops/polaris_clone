# frozen_string_literal: true
class AddConstraintsToHubAvailabilities < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :trucking_hub_availabilities, %i[
      hub_id
      type_availability_id
    ],
      unique: true,
      where: "deleted_at is null",
      algorithm: :concurrently,
      name: "trucking_hub_avilabilities_unique_index"
  end
end
