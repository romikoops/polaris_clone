class CreateUsersClientSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :users_client_settings, id: :uuid do |t|
      t.references :user, type: :uuid,
                          foreign_key: {to_table: :users_clients, on_delete: :cascade},
                          index: {unique: true}

      t.string :locale, default: "en-GB"
      t.string :language, default: "en-GB"
      t.string :currency, default: "EUR"

      t.timestamps
    end
  end
end
