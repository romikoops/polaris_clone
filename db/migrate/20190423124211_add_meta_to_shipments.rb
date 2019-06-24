# frozen_string_literal: true

class AddMetaToShipments < ActiveRecord::Migration[5.2]
  def up
    add_column :shipments, :meta, :jsonb
    change_column_default :shipments, :meta, {}
  end

  def down
    remove_column :shipments, :meta
  end
end
