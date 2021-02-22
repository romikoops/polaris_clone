# frozen_string_literal: true
class AddForeignKeyConstraintsForNexusesToShipment < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :shipments, :nexuses, column: :origin_nexus_id, on_delete: :nullify, validate: false
    add_foreign_key :shipments, :nexuses, column: :destination_nexus_id, on_delete: :nullify, validate: false
  end
end
