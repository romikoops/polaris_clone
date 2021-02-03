require "rails_helper"

RSpec.describe CorrectInvalidUsersClientSettingsWorker, type: :worker do
  let(:organization_with_scope_currency) {
    FactoryBot.create(:organizations_organization, scope: scope_with_currency)
  }
  let(:organization_without_scope_currency) {
    FactoryBot.create(:organizations_organization, scope: scope_without_currency)
  }
  let(:scope_with_currency) {
    FactoryBot.build(:organizations_scope, content: {default_currency: organization_currency})
  }
  let(:scope_without_currency) {
    FactoryBot.build(:organizations_scope, content: {})
  }

  let!(:user_with_scope_currency) do
    FactoryBot.create(:users_client,
      settings: FactoryBot.build(:users_client_settings, currency: nil),
      organization: organization_with_scope_currency)
  end
  let!(:user_without_scope_currency) do
    FactoryBot.create(:users_client,
      settings: FactoryBot.build(:users_client_settings, currency: nil),
      organization: organization_without_scope_currency)
  end
  let(:organization_currency) { "USD" }
  let(:default_currency) { Organizations::DEFAULT_SCOPE["default_currency"] }
  let(:organization_settings) { Users::ClientSettings.find_by(user: user_with_scope_currency) }
  let(:default_settings) { Users::ClientSettings.find_by(user: user_without_scope_currency) }

  before do
    described_class.new.perform
  end

  it "updates the settings with the correct currency values", :aggregate_failures do
    expect(organization_settings.currency).to eq(organization_currency)
    expect(default_settings.currency).to eq(default_currency)
  end
end
