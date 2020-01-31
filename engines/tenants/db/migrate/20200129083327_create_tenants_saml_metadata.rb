# frozen_string_literal: true

class CreateTenantsSamlMetadata < ActiveRecord::Migration[5.2]
  def change
    create_table :tenants_saml_metadata, id: :uuid do |t|
      t.string :content
      t.references :tenant, type: :uuid
      t.timestamps
    end
  end
end
