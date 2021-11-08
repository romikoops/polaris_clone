# frozen_string_literal: true

class BackfillUsersClientsWithNoSettingsOrProfilesWorker
  include Sidekiq::Worker

  def perform
    backfill_users_clients_with_no_profiles
    backfill_users_clients_with_no_settings
  end

  private

  def backfill_users_clients_with_no_profiles
    Users::Client.global.where.not(id: Users::ClientProfile.select(:user_id)).each do |users_client|
      users_client.profile = Users::ClientProfile.new
      # Some do not have a client setting either, therefore when saving, it blows up due to settings presence validation
      users_client.settings = Users::ClientSettings.new(currency: users_client.organization_currency) if users_client.settings.blank?
      users_client.save!
    end
  end

  def backfill_users_clients_with_no_settings
    Users::Client.global.where.not(id: Users::ClientSettings.select(:user_id)).each do |users_client|
      users_client.settings = Users::ClientSettings.new(currency: users_client.organization_currency)
      users_client.save!
    end
  end
end
