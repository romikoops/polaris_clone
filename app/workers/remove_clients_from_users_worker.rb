# frozen_string_literal: true
class RemoveClientsFromUsersWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(*args)
    ActiveRecord::Base.connection.execute("
      DELETE FROM users_settings
      USING users_users
      WHERE users_users.id = users_settings.user_id
      AND users_users.type = 'Organizations::User'
    ")

    ActiveRecord::Base.connection.execute("
      DELETE FROM users_profiles
      USING users_users
      WHERE users_users.id = users_profiles.user_id
      AND users_users.type = 'Organizations::User'
    ")

    ActiveRecord::Base.connection.execute("
      DELETE FROM users_users
      USING users_clients
      WHERE users_clients.id = users_users.id
      AND users_users.type = 'Organizations::User'
    ")
  end
end
