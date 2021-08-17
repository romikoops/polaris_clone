# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizationManager::HierarchyService do
  describe "#perform" do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
    let(:user) { FactoryBot.create(:users_client, organization: organization) }

    context "when user is nil" do
      let(:user) { nil }

      it "returns an empty array" do
        expect(described_class.new(target: user).fetch).to eq([])
      end
    end

    context "when user is not nil" do
      it "returns the correct hierarchy" do
        expect(described_class.new(target: user, organization: organization).fetch).to eq(
          [organization, default_group, user]
        )
      end
    end

    context "when target is a group" do
      let(:group) { FactoryBot.create(:groups_group, organization: organization) }
      let(:membership) { FactoryBot.create(:groups_membership, group: group, member: user) }

      it "returns the correct hierarchy with one group" do
        expect(described_class.new(target: group, organization: organization).fetch).to eq(
          [organization, default_group, group]
        )
      end
    end

    context "when target is a company" do
      let(:company) { FactoryBot.create(:companies_company, organization: organization) }
      let(:member) { FactoryBot.create(:companies_membership, client: user, company: company) }

      it "returns the correct hierarchy with one group" do
        expect(described_class.new(target: company, organization: organization).fetch).to eq(
          [organization, default_group, company]
        )
      end
    end
  end
end
