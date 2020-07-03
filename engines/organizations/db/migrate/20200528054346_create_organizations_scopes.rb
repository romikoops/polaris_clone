# frozen_string_literal: true

class CreateOrganizationsScopes < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations_scopes, id: :uuid do |t|
      t.references :target, polymorphic: true, index: {unique: true}, type: :uuid
      t.jsonb :content

      t.timestamps
    end
  end
end
