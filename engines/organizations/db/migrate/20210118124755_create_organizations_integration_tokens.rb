# frozen_string_literal: true
class CreateOrganizationsIntegrationTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations_integration_tokens, id: :uuid do |t|
      t.references :organization, type: :uuid, index: true, foreign_key: {to_table: :organizations_organizations}
      t.uuid :token
      t.string :scope
      t.string :description
      t.datetime :expires_at

      t.timestamps
    end
  end
end
