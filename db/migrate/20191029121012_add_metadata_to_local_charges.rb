# frozen_string_literal: true

class AddMetadataToLocalCharges < ActiveRecord::Migration[5.2]
  def up
    add_column :local_charges, :metadata, :jsonb
    change_column_default :local_charges, :metadata, {}
  end

  def down
    remove_column :local_charges, :metadata
  end
end
