# frozen_string_literal: true

class RenameShipperIdFromContacts < ActiveRecord::Migration[5.1]
  def change
    rename_column :contacts, :shipper_id, :user_id
  end
end
