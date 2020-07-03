# frozen_string_literal: true

class UsersUsersExternal < ActiveRecord::Migration[5.2]
  def change
    create_table :users_authentications, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: {to_table: :users_users}, index: true
      t.string :provider, :uid, null: false

      t.timestamps null: false

      t.index %i[provider uid], name: :provider_uid_on_users_authentications
    end
  end
end
