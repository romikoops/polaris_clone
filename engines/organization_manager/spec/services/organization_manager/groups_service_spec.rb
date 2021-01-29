# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizationManager::GroupsService do
  describe "#perform" do
    let!(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
    let(:user) { FactoryBot.create(:users_client, organization: organization) }
    let(:group) { FactoryBot.create(:groups_group, organization: organization) }
    let(:target) { user }
    let(:exclude_default) { false }
    let(:groups) do
      described_class.new(
        target: target, organization: organization, exclude_default: exclude_default
      ).fetch
    end

    context "user is nil" do
      let(:target) { nil }

      it "returns an empty array" do
        expect(groups).to eq([default_group])
      end
    end

    context "user is not nil" do
      it "returns the correct hierarchy" do
        expect(groups).to eq([default_group])
      end
    end

    context "user is not nil and exclude_default is true" do
      let(:exclude_default) { true }

      it "returns the correct hierarchy" do
        expect(groups).to eq([])
      end
    end

    context "when target is a group" do
      before { FactoryBot.create(:groups_membership, group: group, member: user) }

      it "returns the correct hierarchy with one group" do
        expect(groups).to eq([group, default_group])
      end
    end

    context "when target is a company" do
      let(:company) { FactoryBot.create(:companies_company, organization: organization) }
      let(:company_group) { FactoryBot.create(:groups_group, organization: organization) }

      before do
        FactoryBot.create(:companies_membership, member: user, company: company)
        FactoryBot.create(:groups_membership, group: company_group, member: company)
      end

      it "returns the correct hierarchy with one group" do
        expect(groups).to eq([company_group, default_group])
      end
    end
  end
end
