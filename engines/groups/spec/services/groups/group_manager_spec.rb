# frozen_string_literal: true

require "rails_helper"

RSpec.describe Groups::GroupManager do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:group) { FactoryBot.create(:groups_group, organization: organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:company) { FactoryBot.create(:companies_company, organization: organization) }
  let(:member_group) { FactoryBot.create(:groups_group, organization: organization, name: "Member Group") }

  describe ".perform" do
    context "when adding" do
      it "adds the user to the group" do
        described_class.new(group_id: group.id, actions: {add: [user]}).perform
        expect(group.members).to eq([user])
      end

      it "adds the company to the group" do
        described_class.new(group_id: group.id, actions: {add: [company]}).perform
        expect(group.members).to eq([company])
      end

      it "adds the group to the group" do
        described_class.new(group_id: group.id, actions: {add: [member_group]}).perform
        expect(group.members).to eq([member_group])
      end
    end

    context "when removing" do
      before do
        FactoryBot.create(:groups_membership, member: target, group: group)
        described_class.new(group_id: group.id, actions: {remove: [target]}).perform
      end

      context "when removing a user" do
        let(:target) { user }

        it "removes the user from the group" do
          expect(group.members).to eq([])
        end
      end

      context "when removing a company" do
        let(:target) { company }

        it "removes the company from the group" do
          expect(group.members).to eq([])
        end
      end

      context "when removing a group" do
        let(:target) { member_group }

        it "removes the group from the group" do
          expect(group.members).to eq([])
        end
      end
    end
  end
end
