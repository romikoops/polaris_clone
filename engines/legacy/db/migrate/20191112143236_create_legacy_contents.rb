# frozen_string_literal: true

class CreateLegacyContents < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_contents, id: :uuid do |t|
      t.string :component, index: true
      t.integer :index
      t.string :section
      t.integer :tenant_id, index: true
      t.jsonb :text, default: {}
      t.timestamps
    end
  end
end
