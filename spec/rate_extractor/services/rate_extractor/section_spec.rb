# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RateExtractor::Section do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:path) { FactoryBot.create_list(:routing_route_line_service, 3) }

  let(:service) { described_class.new(organization: organization, user: user, path: path) }

  describe 'dedicated pricings' do
    context "when applicable to a group" do
      let(:group) do
        FactoryBot.create(:groups_group, organization: organization).tap do |g|
          FactoryBot.create(:groups_membership, group: g, member: user)
        end
      end

      let!(:group_rates) do
        path.map do |section|
          FactoryBot.create(:rates_section,
            target: section,
            applicable_to: group,
            organization: organization)
        end
      end

      let!(:org_rates) do
        path.map do |section|
          FactoryBot.create(:rates_section,
            target: section,
            applicable_to: organization,
            organization: organization)
        end
      end

      let!(:unapplicable_group_rates) do
        FactoryBot.create_list(:rates_section, 2, :group)
      end

      it "finds the applicable rates" do
        expect(service.rates).to match_array [*group_rates, *org_rates]
      end

      it "does not find the unapplicable rates" do
        expect(service.rates).not_to include unapplicable_group_rates
      end
    end

    context "when applicable to a company" do
      let(:company) do
        FactoryBot.create(:companies_company, organization: organization).tap do |c|
          FactoryBot.create(:companies_membership, company: c, member: user)
        end
      end

      let!(:company_rates) do
        path.map do |section|
          FactoryBot.create(:rates_section,
            target: section,
            applicable_to: company,
            organization: organization)
        end
      end

      it "finds the applicable margins" do
        expect(service.rates).to match_array company_rates
      end
    end

    context "when applicable to a user" do
      let!(:user_rates) do
        path.map do |section|
          FactoryBot.create(:rates_section,
            target: section,
            applicable_to: user,
            organization: organization)
        end
      end

      it "finds the applicable margins" do
        expect(service.rates).to match_array user_rates
      end
    end
  end
end
