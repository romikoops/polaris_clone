class CreateOrganizationsSamlMetadata < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations_saml_metadata, id: :uuid do |t|
      t.references :organization, type: :uuid, index: true, foreign_key: {to_table: :organizations_organizations}
      t.text :content

      t.timestamps
    end
  end
end
