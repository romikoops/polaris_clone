# frozen_string_literal: true

class CreateDoorkeeperTables < ActiveRecord::Migration[5.2]
  def change
    create_table :oauth_applications, id: :uuid do |t|
      t.string :name, null: false
      t.string :uid, null: false
      t.string :secret, null: false
      t.text :redirect_uri, null: false
      t.string :scopes, null: false, default: ""
      t.boolean :confidential, null: false, default: true
      t.timestamps null: false
    end

    add_index :oauth_applications, :uid, unique: true

    create_table :oauth_access_grants, id: :uuid do |t|
      t.references :resource_owner, type: :uuid, null: false
      t.references :application, type: :uuid, null: false
      t.string :token, null: false
      t.integer :expires_in, null: false
      t.text :redirect_uri, null: false
      t.datetime :created_at, null: false
      t.datetime :revoked_at
      t.string :scopes
    end

    add_index :oauth_access_grants, :token, unique: true
    add_foreign_key(
      :oauth_access_grants,
      :oauth_applications,
      column: :application_id
    )

    create_table :oauth_access_tokens, id: :uuid do |t|
      t.references :resource_owner, type: :uuid, index: true
      t.references :application, type: :uuid

      t.string :token, null: false

      t.string :refresh_token
      t.integer :expires_in
      t.datetime :revoked_at
      t.datetime :created_at, null: false
      t.string :scopes

      t.string :previous_refresh_token, null: false, default: ""
    end

    add_index :oauth_access_tokens, :token, unique: true
    add_index :oauth_access_tokens, :refresh_token, unique: true
    add_foreign_key(
      :oauth_access_tokens,
      :oauth_applications,
      column: :application_id
    )
  end
end
