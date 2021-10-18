# frozen_string_literal: true

class RemoveUuidConstraintOnLocalCharges < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    remove_index(:local_charges, column: :uuid, name: :index_local_charges_on_uuid) # Removing unique constraint
  end
end
