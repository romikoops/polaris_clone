# frozen_string_literal: true

class CreateOrganizationsMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations_memberships, id: :uuid do |t|
      t.references :user, foreign_key: {to_table: :users_users}, type: :uuid
      t.references :organization, foreign_key: {to_table: :organizations_organizations}, type: :uuid

      t.integer :role, null: false, index: true

      t.timestamps

      t.index %i[user_id organization_id], unique: true
    end
  end
end
