# frozen_string_literal: true

class AddInternalFlagToLocalCharges < ActiveRecord::Migration[5.2]
  def change
    add_column :local_charges, :internal, :boolean, index: true
    change_column_default :local_charges, :internal, false
  end
end
