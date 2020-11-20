class CorrectingUniquenessConstraints < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :routing_carriers, %i[name code abbreviated_name],
      unique: true, name: "routing_carriers_index", algorithm: :concurrently
  end
end
