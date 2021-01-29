class RemoveClientsFromUsersWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(*args)
    ActiveRecord::Base.connection.execute("
      DELETE FROM users_users
      JOIN users_clients
      ON users_clients.id = users_users.id
      AND users_users.type = 'Organizations::User'
    ")
  end
end
