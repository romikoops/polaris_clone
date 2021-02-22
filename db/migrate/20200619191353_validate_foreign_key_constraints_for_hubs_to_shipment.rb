# frozen_string_literal: true
class ValidateForeignKeyConstraintsForHubsToShipment < ActiveRecord::Migration[5.2]
  def change
    validate_foreign_key :shipments, {column: :origin_hub_id, on_delete: :nullify}
    validate_foreign_key :shipments, {column: :destination_hub_id, on_delete: :nullify}
  end
end
