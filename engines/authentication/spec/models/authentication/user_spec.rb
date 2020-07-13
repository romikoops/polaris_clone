require "rails_helper"

module Authentication
  RSpec.describe User, type: :model do
    let(:email) { "email@itsmytest.com" }
    let(:organization) { FactoryBot.create(:organizations_organization) }

    before do
      Organizations.current_id = organization.id
      FactoryBot.create(:organizations_user, email: email)
    end

    describe "authentication_scope memberships" do
      let(:user) { FactoryBot.create(:users_user, email: email) }

      before do
        FactoryBot.create(:organizations_membership, organization: organization, user: user)
      end

      it "returns users beloning to the current organization" do
        expect(described_class.authentication_scope.find_by(email: email).id).to eq(user.id)
      end
    end

    describe "authentication_scope default users" do
      it "returns users beloning to the current organization" do
        user = FactoryBot.create(:organizations_user, email: email, organization: organization)

        expect(described_class.authentication_scope.find_by(email: email).id).to eq(user.id)
      end
    end

    describe "with_membership" do
      let(:user) { FactoryBot.create(:users_user, email: email) }

      before do
        Organizations.current_id = nil
        FactoryBot.create(:organizations_membership, organization: organization, user: user)
      end

      it "returns users beloning that belongs to at least one organization" do
        expect(described_class.with_membership.find_by(email: email).id).to eq(user.id)
      end
    end

    context "when creeating and default group exists" do
      let(:user) { FactoryBot.create(:authentication_user, :organizations_user, organization_id: organization.id) }
      let!(:default_group) { FactoryBot.create(:groups_group, name: "default", organization: organization) }

      it "attaches to the default group" do
        aggregate_failures do
          expect(user).to be_valid
          expect(Groups::Membership.find_by(member: user, group: default_group)).to be_present
        end
      end
    end
  end
end
