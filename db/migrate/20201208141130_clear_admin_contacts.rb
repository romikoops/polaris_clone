# frozen_string_literal: true
class ClearAdminContacts < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      execute <<-SQL
        DELETE FROM contacts
        WHERE
          id IN (
            SELECT c.id
            FROM contacts c
            LEFT JOIN users_users u ON u.id = c.user_id
            WHERE u.type = 'Users::User'
          )
      SQL
    end
  end
end
