# frozen_string_literal: true

class CreateAgencies < ActiveRecord::Migration[5.1]
  def change
    create_table :agencies do |t|
      t.string :name
      t.integer :tenant_id
      t.integer :agency_manager_id
      t.timestamps
    end
  end
end
