# frozen_string_literal: true

class CreateTenantsThemes < ActiveRecord::Migration[5.2]
  def change
    create_table :tenants_themes, id: :uuid do |t|
      t.uuid :tenant_id, index: true
      t.string :primary_color
      t.string :secondary_color
      t.string :bright_primary_color
      t.string :bright_secondary_color
      t.string :welcome_text
      t.timestamps
    end
  end
end
