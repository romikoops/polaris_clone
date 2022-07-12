# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::Admin::GroupsMembershipDecorator do
  let(:group) { FactoryBot.create(:groups_group, name: "default_group") }
  let(:member) { FactoryBot.create(:companies_company, name: "abc company") }
  let(:groups_membership) { Api::GroupsMembership.create(group: group, member: member) }
  let(:decorated_groups_membership) { described_class.new(groups_membership) }

  before { groups_membership }

  describe "#name" do
    context "with company as member" do
      it "returns company_name as name" do
        expect(decorated_groups_membership.name).to eq(member.name)
      end
    end

    context "with group as member" do
      let(:member) { FactoryBot.create(:groups_group, name: "demo_group") }

      it "returns group_name as name" do
        expect(decorated_groups_membership.name).to eq(member.name)
      end
    end

    context "with users client as member" do
      let(:member) { FactoryBot.create(:users_client, profile: FactoryBot.build(:users_client_profile, first_name: "Bob")) }

      it "returns client's first_name as name" do
        expect(decorated_groups_membership.name).to eq(member.first_name)
      end
    end

    context "with unknown as a member" do
      let(:member) { nil }

      it "returns empty string as name" do
        expect(decorated_groups_membership.name).to eq("")
      end
    end
  end
end
