# frozen_string_literal: true

class CreateUsersUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users_users, id: :uuid do |t|
      t.string :email
      t.string :name
      t.string :google_id

      t.timestamps
    end
  end
end
