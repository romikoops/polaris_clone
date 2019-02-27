# frozen_string_literal: true

class CreateAddons < ActiveRecord::Migration[5.1]
  def change
    create_table :addons do |t|
      t.string :title
      t.jsonb :text, array: true, default: []
      t.integer :tenant_id
      t.string :read_more
      t.string :accept_text
      t.string :decline_text
      t.string :additional_info_text
      t.string :cargo_class
      t.integer :hub_id
      t.integer :counterpart_hub_id
      t.string :mode_of_transport
      t.integer :tenant_vehicle_id
      t.integer :counterpart_hub_id
      t.string :direction
      t.string :addon_type
      t.jsonb :fees
      t.timestamps
    end
  end
end
