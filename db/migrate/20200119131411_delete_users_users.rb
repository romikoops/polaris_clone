# frozen_string_literal: true

class DeleteUsersUsers < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      drop_table :users_users do |t|
        t.string 'email'
        t.string 'google_id'
        t.datetime 'last_activity_at'
        t.datetime 'last_login_at'
        t.string 'last_login_from_ip_address'
        t.datetime 'last_logout_at'
        t.string 'name'
      end
    end
  end
end
