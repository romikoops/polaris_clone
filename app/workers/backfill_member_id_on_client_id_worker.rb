# frozen_string_literal: true

class BackfillMemberIdOnClientIdWorker
  include Sidekiq::Worker

  def perform
    ActiveRecord::Base.connection.execute(
      <<~SQL
        DELETE from companies_memberships
        WHERE member_id not in (SELECT id from users_clients)
      SQL
    )
    ActiveRecord::Base.connection.execute(
      <<~SQL
        UPDATE companies_memberships
        SET client_id = member_id
      SQL
    )
  end
end
