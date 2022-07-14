# frozen_string_literal: true

class CreateLedgerCurrentBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :ledger_current_books, id: :uuid do |t|
      t.references :organization, type: :uuid, index: true, null: false, foreign_key: { to_table: "organizations_organizations" }
      t.references :book, type: :uuid, index: true, null: false
      t.references :user, type: :uuid, index: true, null: false, foreign_key: { to_table: "users_users" }

      t.timestamps
    end
  end
end
