# frozen_string_literal: true
class BackfillTestShipments < ActiveRecord::Migration[5.2]
  def change
    exec_update <<~SQL
      UPDATE shipments
      SET billing = 2
      FROM users_users
      WHERE shipments.user_id = users_users.id
      AND users_users.email LIKE '%@itsmycargo.com'
      AND shipments.billing IS NULL
    SQL
  end
end
