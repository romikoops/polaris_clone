class BackfillBillingEnumsToShipmentRequests < ActiveRecord::Migration[5.2]
  def up
    exec_update <<-SQL
    UPDATE shipments_shipment_requests
    SET billing = 0
    SQL

    exec_update <<-SQL
          WITH test_users as (
            SELECT users_users.*
            FROM  users_users
            WHERE users_users.email ILIKE '%@itsmycargo.com'
          )
          UPDATE shipments_shipment_requests
          SET billing = 2
          FROM test_users
          WHERE shipments_shipment_requests.user_id = test_users.id
    SQL

    exec_update <<-SQL
          WITH internal_users as (
            SELECT users_users.*
            FROM  users_users
            JOIN migrator_syncs ON migrator_syncs.users_user_id = users_users.id
            JOIN users ON migrator_syncs.user_id = users.id
            WHERE users.internal IS TRUE
            AND users_users.email NOT ILIKE '%@itsmycargo.com'
          )
          UPDATE shipments_shipment_requests
          SET billing = 1
          FROM internal_users
          WHERE shipments_shipment_requests.user_id = internal_users.id
    SQL
  end

  def down
  end
end
