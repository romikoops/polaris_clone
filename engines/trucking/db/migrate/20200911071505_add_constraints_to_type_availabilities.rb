class AddConstraintsToTypeAvailabilities < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :trucking_type_availabilities, %i[
      carriage
      load_type
      country_id
      truck_type
      query_method
    ],
      unique: true,
      where: "deleted_at is null",
      algorithm: :concurrently,
      name: "trucking_type_availabilities_unique_index"
  end
end
