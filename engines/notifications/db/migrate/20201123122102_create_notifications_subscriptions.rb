class CreateNotificationsSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications_subscriptions do |t|
      t.string :event_type, index: true
      t.json :filter, default: "{}"
      t.references :user, type: :uuid, index: true, foreign_key: {to_table: :users_users}
      t.references :organization, type: :uuid, index: true, foreign_key: {to_table: :organizations_organizations}
      t.string :email, index: true

      t.timestamps
    end
  end
end
