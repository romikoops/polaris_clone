# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiAuth::ResourceHelper do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:resource_for_login) { described_class.resource_for_login(client: client) }

  before do
    Organizations.current_id = organization.id
  end

  describe ".resource_for_login" do
    describe "admin authentication for bridge" do
      let(:client) { double("client", name: "bridge") }

      context "when a user with membership exists" do
        let!(:user) do
          FactoryBot.create(:authentication_user, :users_user).tap do |user|
            FactoryBot.create(:organizations_membership, organization: organization, user: user)
          end
        end

        it "finds users with memberships" do
          expect(resource_for_login.ids).to eq [user.id]
        end
      end

      context "when user not found" do
        before do
          FactoryBot.create(:authentication_user, :users_user)
        end

        it "finds returns empty collection" do
          expect(resource_for_login).to be_empty
        end
      end
    end

    describe "non-admin authentication" do
      let(:client) { nil }

      context "when organization user exists" do
        let!(:user) { FactoryBot.create(:authentication_user, :organizations_user, organization_id: organization.id) }

        it "finds users for the current organization" do
          expect(resource_for_login.ids).to eq [user.id]
        end
      end

      context "when no users exist for the current organization" do
        let(:another_org) { FactoryBot.create(:organizations_organization) }

        before do
          FactoryBot.create(:authentication_user, :organizations_user, organization_id: another_org.id)
        end

        it "finds no organization users" do
          expect(resource_for_login).to be_empty
        end
      end
    end
  end
end
