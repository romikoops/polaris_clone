# frozen_string_literal: true

class AddGroupIdToLocalCharge < ActiveRecord::Migration[5.2]
  def change
    add_column :local_charges, :group_id, :uuid, index: true
  end
end
