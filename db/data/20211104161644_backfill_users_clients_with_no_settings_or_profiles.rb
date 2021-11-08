# frozen_string_literal: true

class BackfillUsersClientsWithNoSettingsOrProfiles < ActiveRecord::Migration[5.2]
  def up
    BackfillUsersClientsWithNoSettingsOrProfilesWorker.perform_async
  end
end
