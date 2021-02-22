# frozen_string_literal: true
class ClearAdminAddressbookContacts < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      execute <<-SQL
        DELETE FROM address_book_contacts
        WHERE
          id IN (
            SELECT c.id
            FROM address_book_contacts c
            LEFT JOIN users_users u on u.id = c.user_id
            WHERE u.type = 'Users::User'
          )
      SQL
    end
  end
end
