# frozen_string_literal: true

class CreateLedgerBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :ledger_books, id: :uuid do |t|
      t.string :name, null: false, index: { unique: true }
      t.references :basis_book, type: :uuid, index: true
      t.references :upload, type: :uuid, index: true, null: false
      t.references :user, type: :uuid, index: true, null: false, foreign_key: { to_table: "users_users" }
      t.string :aasm_state, default: "draft"
      t.datetime :published_at

      t.timestamps
    end
  end
end
