class ValidateForeignKeyConstraintsForNexusesToShipment < ActiveRecord::Migration[5.2]
  def change
    validate_foreign_key :shipments, {column: :origin_nexus_id, on_delete: :nullify}
    validate_foreign_key :shipments, {column: :destination_nexus_id, on_delete: :nullify}
  end
end
