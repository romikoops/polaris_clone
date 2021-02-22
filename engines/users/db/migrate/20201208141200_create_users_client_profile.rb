# frozen_string_literal: true
class CreateUsersClientProfile < ActiveRecord::Migration[5.2]
  def change
    create_table :users_client_profiles, id: :uuid do |t|
      t.references :user, type: :uuid,
                          foreign_key: {to_table: :users_clients, on_delete: :cascade},
                          index: {unique: true}

      t.string :first_name
      t.string :last_name
      t.string :company_name
      t.string :phone
      t.datetime :deleted_at
      t.string :external_id

      t.timestamps
    end
  end
end
