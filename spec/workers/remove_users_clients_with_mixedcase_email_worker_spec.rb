# frozen_string_literal: true

require "rails_helper"
RSpec.describe RemoveUsersClientsWithMixedcaseEmailWorker, type: :worker do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:existing_users_client) { FactoryBot.create(:users_client, email: "user.test@itsmycargo.com", organization: organization) }
  let(:organization_group) { Groups::Group.create(organization: organization) }
  let!(:mixed_case_users_client) do
    FactoryBot.build(:users_client, email: "User.Test@itsmycargo.com",
                                    deleted_at: 2.minutes.ago, organization: organization).tap { |user_client| user_client.save(validate: false) }
  end
  let!(:journey_query) { FactoryBot.create(:journey_query, client: mixed_case_users_client) }
  let!(:companies_membership) { FactoryBot.create(:companies_membership, member: mixed_case_users_client) }
  let!(:groups_membership) { FactoryBot.create(:groups_membership, group: organization_group, member: mixed_case_users_client) }

  before do
    described_class.new.perform
    journey_query.reload
    companies_membership.reload
    groups_membership.reload
  end

  describe "#perform", skip: "DB constraint added so the test would not work" do
    subject { existing_users_client.id }

    it "deletes the mixed users client" do
      expect(Users::Client.global.exists?(mixed_case_users_client.id)).to be false
    end

    it { is_expected.to eq journey_query.client_id }
    it { is_expected.to eq companies_membership.member_id }
    it { is_expected.to eq groups_membership.member_id }
  end
end
