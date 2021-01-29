class CreateUsersAdmins < ActiveRecord::Migration[5.2]
  def change
    create_table :users_admins, id: :uuid do |t|
      # Core
      t.string :email, null: false, index: true, unique: true
      t.string :crypted_password
      t.string :salt

      # Activity Logging
      t.datetime :last_login_at, default: nil
      t.datetime :last_activity_at, default: nil
      t.string :last_login_from_ip_address, default: nil

      t.timestamps null: false
    end
  end
end
