# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::UserDecorator do
  let(:user) { FactoryBot.create(:users_user) }
  let(:organization) { FactoryBot.create(:organizations_organization) }

  let(:decorated_result) { described_class.new(user) }

  before do
    ::Organizations.current_id = organization.id
  end

  describe "#first_name" do
    context "with valid email and user present" do
      it "returns first_name of of the user" do
        expect(decorated_result.first_name).to eq user.profile.first_name
      end
    end
  end

  describe "#auth_methods" do
    before { FactoryBot.create(:users_membership, organization: organization, user: user) }

    it "returns support auth methods for the user" do
      expect(decorated_result.auth_methods).to eq ["password"]
    end

    context "when Saml Metadatum exists for an organization" do
      before { FactoryBot.create(:organizations_saml_metadatum, organization: organization) }

      it "returns both `password` and `saml` as auth methods" do
        expect(decorated_result.auth_methods).to match_array %w[password saml]
      end
    end
  end
end
