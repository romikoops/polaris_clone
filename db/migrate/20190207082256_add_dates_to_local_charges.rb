# frozen_string_literal: true

class AddDatesToLocalCharges < ActiveRecord::Migration[5.2]
  def up
    add_column :local_charges, :effective_date, :datetime
    add_column :local_charges, :expiration_date, :datetime
    add_column :local_charges, :user_id, :integer
    add_column :local_charges, :uuid, :uuid
    change_column_default :local_charges, :uuid, "gen_random_uuid()"
  end

  def down
    remove_column :local_charges, :uuid
  end
end
