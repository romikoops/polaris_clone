# frozen_string_literal: true
class CorrectInvalidUsersClientSettings < ActiveRecord::Migration[5.2]
  def up
    CorrectInvalidUsersClientSettingsWorker.perform_async
  end
end
