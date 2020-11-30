# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::UserRestorationService do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, :with_profile, organization: organization) }
  let(:service) { described_class.new(user_id: user.id, organization_id: organization.id, params: params) }
  let(:group) { FactoryBot.create(:groups_group, organization: organization) }

  describe ".restore" do
    let(:params) do
      FactoryBot.attributes_for(:profiles_profile)
    end

    before do
      Organizations.current_id = organization.id
      FactoryBot.create(:groups_membership, group: group, member: user)
      user.destroy
    end

    it "restores the user" do
      service.restore
      expect(Organizations::User.find(user.id)).to eq(user)
    end

    it "restores and updates the user settings and user profile" do
      service.restore
      aggregate_failures do
        expect(Users::Settings.where(user_id: user.id)).to exist
        expect(Profiles::Profile.where(user_id: user.id)).to exist
      end
    end

    it "restores deleted groups memberships" do
      service.restore
      expect(Groups::Membership.where(member: user)).to exist
    end
  end
end
