# frozen_string_literal: true

class CreateOrganizationsThemes < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations_themes, id: :uuid do |t|
      t.references :organization, index: {unique: true},
                                  foreign_key: {to_table: :organizations_organizations}, type: :uuid

      t.string :name
      t.string :welcome_text

      t.string :primary_color
      t.string :secondary_color
      t.string :bright_primary_color
      t.string :bright_secondary_color
      t.jsonb :emails
      t.jsonb :phones
      t.jsonb :addresses
      t.jsonb :email_links

      t.timestamps
    end
  end
end
