# frozen_string_literal: true

class AddDangerousToLocalCharges < ActiveRecord::Migration[5.1]
  def change
    add_column :local_charges, :dangerous, :boolean, default: false
  end
end
