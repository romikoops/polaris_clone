# frozen_string_literal: true

require "rails_helper"

RSpec.describe RateExtractor::TenderFees do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:path) { FactoryBot.create_list(:routing_route_line_service, 3) }
  let(:quotations_tender) { FactoryBot.create(:quotations_tender) }

  let(:tender) do
    RateExtractor::Decorators::Tender.new(quotations_tender).tap do |tender|
      tender.path = path
    end
  end

  let(:cargo) do
    FactoryBot.create(:cargo_cargo, quotation_id: tender.quotation_id).tap do |cargo|
      FactoryBot.create_list(:lcl_unit, 2, cargo: cargo)
    end
  end

  let(:section_rates) do
    path.map do |section|
      FactoryBot.create(:rates_section,
        target: section,
        applicable_to: user,
        organization: organization)
    end
  end

  let!(:unapplicable_section_rate) { FactoryBot.create(:rates_section, organization: organization) }

  let(:cargo_rates) do
    section_rates.map do |section|
      FactoryBot.create(:rates_cargo, :lcl, section: section, cbm_ratio: 200)
    end
  end

  let!(:unapplicable_cargo_rate) { FactoryBot.create(:rates_cargo, :container_20, section: section_rates.first) }

  let!(:fees) do
    cargo_rates.map do |cargo|
      FactoryBot.create(:rates_fee, cargo: cargo)
    end
  end

  let(:klass) {
    described_class.new(organization: organization, tender: tender, user: user,
                        desired_date: 1.month.from_now, cargo: cargo)
  }

  let(:decorated_section) { instance_double(RateExtractor::Decorators::SectionRate) }

  before do
    allow(RateExtractor::Decorators::SectionRate).to receive(:new).and_return(decorated_section)
    allow(decorated_section).to receive(:carriage_distance).and_return(6)
  end

  context "when tender has fees" do
    it "finds the applicable section rates" do
      expect(klass.section_rates).to match_array section_rates
    end

    it "filters out the un applicable section rates" do
      expect(klass.section_rates).not_to include unapplicable_section_rate
    end

    it "finds the applicable cargo rates" do
      expect(klass.cargo_rates).to match_array cargo_rates
    end

    it "filters out the un applicable cargo rates" do
      expect(klass.cargo_rates).not_to include unapplicable_cargo_rate
    end

    it "returns the applicable fees" do
      expect(klass.fees.flatten.pluck(:id)).to match_array fees.pluck(:id)
    end
  end
end
