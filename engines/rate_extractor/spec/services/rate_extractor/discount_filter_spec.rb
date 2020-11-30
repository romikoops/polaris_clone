# frozen_string_literal: true

require "rails_helper"

RSpec.describe RateExtractor::DiscountFilter do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:path) { FactoryBot.create_list(:routing_route_line_service, 3) }
  let(:quotations_tender) { FactoryBot.create(:quotations_tender) }
  let(:quotation) { quotations_tender.quotation }
  let(:tender) do
    RateExtractor::Decorators::Tender.new(quotations_tender).tap do |tender|
      tender.path = path
    end
  end

  let(:cargo) do
    FactoryBot.create(:cargo_cargo, quotation_id: quotation.id, units:
    FactoryBot.create_list(:lcl_unit, 2))
  end

  let!(:section_rates) do
    path.map do |section|
      FactoryBot.create(:rates_section, target: section, applicable_to: organization, organization: organization)
    end
  end

  let!(:unapplicable_section_rate) { FactoryBot.create(:rates_section, organization: organization) }

  let!(:cargo_rates) do
    section_rates.map do |section|
      FactoryBot.create(:rates_cargo, :lcl, section: section, cbm_ratio: 200)
    end
  end
  let(:klass) {
    described_class.new(organization: organization, user: user, tender: tender,
                        desired_date: 1.month.from_now, cargo: cargo)
  }

  context "when target is a section rate" do
    let!(:section_rate_discounts) {
      FactoryBot.create_list(:rates_discount, 2, target: section_rates.first,
                                                 organization: organization, applicable_to: organization)
    }

    let!(:unapplicable_discounts) {
      FactoryBot.create_list(:rates_discount, 2, :section, organization: organization,
                                                           applicable_to: organization)
    }

    it "finds the attached discounts" do
      expect(klass.discounts).to match_array section_rate_discounts
    end
  end

  context "when target is a cargo rate" do
    let!(:cargo_rate_discounts) {
      FactoryBot.create_list(:rates_discount, 2, target: cargo_rates.first,
                                                 organization: organization, applicable_to: organization)
    }

    it "finds the attached discounts" do
      expect(klass.discounts).to match_array cargo_rate_discounts
    end
  end

  context "when target is nil" do
    let!(:non_targeted_discounts) {
      FactoryBot.create_list(:rates_discount, 2, organization: organization, applicable_to: organization)
    }

    it "finds the applicable discounts" do
      expect(klass.discounts).to match_array non_targeted_discounts
    end
  end

  context "when applicable to a group" do
    let(:group) do
      FactoryBot.create(:groups_group, organization: organization).tap do |g|
        FactoryBot.create(:groups_membership, group: g, member: user)
      end
    end

    let!(:group_discounts) {
      FactoryBot.create_list(:rates_discount, 2, organization: organization, applicable_to: group)
    }

    let!(:org_discounts) {
      FactoryBot.create_list(:rates_discount, 2, organization: organization, applicable_to: organization)
    }

    let!(:unapplicable_group_discounts) {
      FactoryBot.create_list(:rates_discount, 2, :group)
    }

    it "finds the applicable discounts" do
      expect(klass.discounts).to match_array [*group_discounts, *org_discounts]
    end
  end

  context "when applicable to a company" do
    let(:company) do
      FactoryBot.create(:companies_company, organization: organization).tap do |c|
        FactoryBot.create(:companies_membership, company: c, member: user)
      end
    end

    let!(:company_discounts) {
      FactoryBot.create_list(:rates_discount, 2, organization: organization, applicable_to: company)
    }

    it "finds the applicable discounts" do
      expect(klass.discounts).to match_array company_discounts
    end
  end

  context "when applicable to a user" do
    let!(:user_discounts) {
      FactoryBot.create_list(:rates_discount, 2, organization: organization, applicable_to: user)
    }

    it "finds the applicable discounts" do
      expect(klass.discounts).to match_array user_discounts
    end
  end

  context "when filtered by validity" do
    let!(:valid_discounts) {
      FactoryBot.create_list(:rates_discount, 2,
        organization: organization, applicable_to: organization, validity: 2.days.from_now..60.days.from_now)
    }

    let!(:invalid_discounts) {
      FactoryBot.create_list(:rates_discount, 2,
        organization: organization, applicable_to: organization, validity: 3.days.ago..2.days.ago)
    }

    it "finds the valid discounts" do
      expect(klass.discounts).to match_array valid_discounts
    end
  end
end
