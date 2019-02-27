# frozen_string_literal: true

class CreateNexuses < ActiveRecord::Migration[5.1]
  def change
    create_table :nexuses do |t|
      t.string :name
      t.integer :tenant_id
      t.float :latitude
      t.float :longitude
      t.string :photo
      t.integer :country_id
      t.timestamps
    end
  end
end
