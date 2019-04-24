# frozen_string_literal: true

class CreateTenantsScopes < ActiveRecord::Migration[5.2]
  def change
    create_table :tenants_scopes, id: :uuid do |t|
      t.references :target, polymorphic: true, index: true, type: :uuid
      t.jsonb :content

      t.timestamps
    end
  end
end
