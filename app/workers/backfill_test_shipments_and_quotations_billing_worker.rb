class BackfillTestShipmentsAndQuotationsBillingWorker
  include Sidekiq::Worker

  def perform(*args)
    %w[shipments quotations].each do |table|
      ActiveRecord::Migration.exec_update("
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
    end

    ActiveRecord::Migration.exec_update("
      WITH test_users as (
        SELECT users_users.*
        FROM  users_users
        WHERE users_users.email ILIKE '%@itsmycargo.com'
      )
      UPDATE quotations_quotations
      SET billing = 2
      FROM test_users
      WHERE quotations_quotations.creator_id = test_users.id
      OR quotations_quotations.user_id = test_users.id
    ")
  end
end
