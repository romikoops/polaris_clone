# frozen_string_literal: true
class RemoveClientsFromUsers < ActiveRecord::Migration[5.2]
  def up
    RemoveClientsFromUsersWorker.perform_async
  end
end
