class CorrectInvalidUsersClientSettingsWorker
  include Sidekiq::Worker

  def perform(*args)
    Users::ClientSettings.where(currency: nil).find_each do |settings|
      user = Users::Client.unscoped.find(settings.user_id)
      currency = OrganizationManager::ScopeService.new(
        target: user, organization: user.organization
      ).fetch(:default_currency)
      settings.update(currency: currency, user: user)
    end
  end
end
