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
          FactoryBot.create(:users_user).tap do |user|
            FactoryBot.create(:users_membership, organization: organization, user: user)
          end
        end

        it "finds users with memberships" do
          expect(resource_for_login.flat_map(&:ids)).to eq [user.id]
        end
      end

      context "when user not found" do
        before do
          FactoryBot.create(:users_user)
        end

        it "finds returns empty collection" do
          expect(resource_for_login).to eq([Users::User])
        end
      end
    end

    describe "non-admin authentication" do
      let(:client) { nil }

      context "when organization user exists" do
        let!(:user) { FactoryBot.create(:users_client, organization: organization) }

        it "finds users for the current organization" do
          expect(resource_for_login.flat_map(&:ids)).to eq [user.id]
        end
      end
    end
  end
end
