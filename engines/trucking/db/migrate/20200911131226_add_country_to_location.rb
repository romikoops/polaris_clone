class AddCountryToLocation < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :trucking_locations, :country, index: {algorithm: :concurrently}
  end
end
