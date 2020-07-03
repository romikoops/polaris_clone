class BackfillBillingEnums < ActiveRecord::Migration[5.2]
  def up
    %w[shipments quotations quotations_quotations].each do |table|
      exec_update("
          WITH test_users as (
            SELECT users_users.*
            FROM  users_users
            WHERE users_users.email ILIKE '%@itsmycargo.com'
          )
          UPDATE #{table}
          SET billing = 2
          FROM test_users
          WHERE #{table}.user_id = test_users.id
        ")

      exec_update("
          WITH internal_users as (
            SELECT users_users.*
            FROM  users_users
            JOIN migrator_syncs ON migrator_syncs.users_user_id = users_users.id
            JOIN users ON migrator_syncs.user_id = users.id
            WHERE users.internal IS TRUE
            AND users_users.email NOT ILIKE '%@itsmycargo.com'
          )
          UPDATE #{table}
          SET billing = 1
          FROM internal_users
          WHERE #{table}.user_id = internal_users.id
        ")
      exec_update("
          WITH external_users as (
            SELECT users_users.*
            FROM  users_users
            JOIN migrator_syncs ON migrator_syncs.users_user_id = users_users.id
            JOIN users ON migrator_syncs.user_id = users.id
            WHERE users.internal IS FALSE
            AND users_users.email NOT ILIKE '%@itsmycargo.com'
          )
          UPDATE #{table}
          SET billing = 0
          FROM external_users
          WHERE #{table}.user_id = external_users.id
        ")
    end
  end

  def down
  end
end
