# frozen_string_literal: true

class CreateContents < ActiveRecord::Migration[5.2]
  def change
    create_table :contents do |t|
      t.jsonb :text, default: {}
      t.string :component
      t.string :section
      t.integer :index
      t.integer :tenant_id
      t.timestamps
    end
  end
end
