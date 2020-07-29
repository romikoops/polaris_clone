# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiAuth::ResourceAuthenticator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:password) { "1234567890" }
  let(:email) { "test@itsmycargo.com" }
  let!(:theme) { FactoryBot.create(:organizations_theme, organization: organization) }
  let!(:user) { FactoryBot.create(:authentication_user, :organizations_user, :active, email: email, password: password, organization_id: organization.id) }
  let(:resource) { ::Authentication::User.authentication_scope }

  before do
    Organizations.current_id = organization.id
  end

  describe ".authenticate" do
    context "when regular login" do
      let(:auth) { described_class.authenticate(resource: resource, email: email, password: password) }

      it "authenticates the user" do
        expect(auth).to eq(user)
      end
    end

    context "when passwordless" do
      before do
        FactoryBot.create(:organizations_scope, target: organization, content: {signup_form_fields: {password: false}})
      end

      let(:auth) { described_class.authenticate(resource: resource, email: email, password: nil) }

      it "returns Authentication::User " do
        expect(auth).to eq(user)
      end
    end
  end
end
