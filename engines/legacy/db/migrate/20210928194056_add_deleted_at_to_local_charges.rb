# frozen_string_literal: true

class AddDeletedAtToLocalCharges < ActiveRecord::Migration[5.2]
  def change
    add_column :local_charges, :deleted_at, :datetime
  end
end
