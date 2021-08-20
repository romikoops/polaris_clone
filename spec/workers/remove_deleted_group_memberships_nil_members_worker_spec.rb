# frozen_string_literal: true

require "rails_helper"
RSpec.describe RemoveDeletedGroupMembershipsNilMembersWorker, type: :worker do
  describe "#perform" do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:organization_group) { Groups::Group.create(organization: organization) }

    context "with deleted Users::Clients" do
      let!(:users_client_deleted) { FactoryBot.create(:users_client, email: "test@itsmycargo.com", deleted_at: 5.minutes.ago) }
      let!(:groups_membership_to_be_deleted) do
        FactoryBot.create(:groups_membership, group: organization_group, member: users_client_deleted)
      end

      it "deletes the group membership whose user client is deleted" do
        expect { described_class.new.perform }.to change {
                                                    Groups::Membership.with_deleted.find(groups_membership_to_be_deleted.id).deleted?
                                                  }.from(false).to(true)
      end

      it "raises an exception if Users::Client member still exist" do
        described_class_instance = described_class.new
        allow(described_class_instance).to receive(:group_memberships_to_be_deleted).and_return([users_client_deleted])
        expect { described_class_instance.perform }.to raise_error(described_class::FailedDeletion)
      end
    end

    context "with deleted Groups::Group" do
      let!(:groups_group_deleted) { FactoryBot.create(:groups_group, deleted_at: 5.minutes.ago) }
      let!(:groups_membership_to_be_deleted) do
        FactoryBot.create(:groups_membership, group: organization_group, member: groups_group_deleted)
      end

      it "deletes the group membership whose groups group is deleted" do
        expect { described_class.new.perform }.to change {
                                                    Groups::Membership.with_deleted.find(groups_membership_to_be_deleted.id).deleted?
                                                  }.from(false).to(true)
      end

      it "raises an exception if Groups::Group still exist" do
        described_class_instance = described_class.new
        allow(described_class_instance).to receive(:group_memberships_to_be_deleted).and_return([groups_group_deleted])
        expect { described_class_instance.perform }.to raise_error(described_class::FailedDeletion)
      end
    end

    context "with deleted Companies::Company" do
      let!(:companies_deleted) { FactoryBot.create(:companies_company, deleted_at: 5.minutes.ago) }
      let!(:groups_membership_to_be_deleted) do
        FactoryBot.create(:groups_membership, group: organization_group, member: companies_deleted)
      end

      it "deletes the group membership whose companies company is deleted" do
        expect { described_class.new.perform }.to change {
                                                    Groups::Membership.with_deleted.find(groups_membership_to_be_deleted.id).deleted?
                                                  }.from(false).to(true)
      end

      it "raises an exception if Companies::Company still exist" do
        described_class_instance = described_class.new
        allow(described_class_instance).to receive(:group_memberships_to_be_deleted).and_return([companies_deleted])
        expect { described_class_instance.perform }.to raise_error(described_class::FailedDeletion)
      end
    end
  end
end
