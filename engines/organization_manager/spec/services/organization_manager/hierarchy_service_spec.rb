# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizationManager::HierarchyService do
  describe "#perform" do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:organizations_user, organization: organization) }

    context "user is nil" do
      let(:user) { nil }

      it "returns an empty array" do
        expect(described_class.new(target: user).fetch).to eq([])
      end
    end

    context "user is not nil" do
      it "returns the correct hierarchy" do
        expect(described_class.new(target: user, organization: organization).fetch).to eq([organization, user])
      end
    end

    context "when target is a group" do
      let(:group) { FactoryBot.create(:groups_group, organization: organization) }
      let(:membership) { FactoryBot.create(:groups_group, group: group, member: user) }

      it "returns the correct hierarchy with one group" do
        expect(described_class.new(target: group, organization: organization).fetch).to eq([organization, group])
      end
    end

    context "when target is a company" do
      let(:company) { FactoryBot.create(:companies_company, organization: organization) }
      let!(:member) { FactoryBot.create(:companies_membership, member: user, company: company) }

      it "returns the correct hierarchy with one group" do
        expect(described_class.new(target: company, organization: organization).fetch).to eq([organization, company])
      end
    end
  end
end
