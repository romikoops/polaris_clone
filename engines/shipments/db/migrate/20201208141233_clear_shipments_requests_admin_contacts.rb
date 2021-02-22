# frozen_string_literal: true
class ClearShipmentsRequestsAdminContacts < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      execute <<-SQL
        DELETE FROM shipments_shipment_request_contacts
        WHERE
          id IN (
            SELECT src.id
            FROM shipments_shipment_request_contacts src
            LEFT JOIN address_book_contacts c ON c.id = src.contact_id
            LEFT JOIN users_users u on u.id = c.user_id
            WHERE u.type = 'Users::User'
          )
      SQL
    end
  end
end
