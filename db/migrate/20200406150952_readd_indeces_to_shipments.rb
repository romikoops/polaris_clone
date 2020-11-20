# frozen_string_literal: true

class ReaddIndecesToShipments < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :shipments, :sandbox_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :shipments, :tenant_id, where: "deleted_at IS NULL", algorithm: :concurrently
  end
end
