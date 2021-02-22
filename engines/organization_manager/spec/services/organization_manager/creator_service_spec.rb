# frozen_string_literal: true
require "rails_helper"

RSpec.describe OrganizationManager::CreatorService do
  let(:params) do
    {
      slug: "tester",
      theme: {
        primary_color: "#000001",
        secondary_color: "#000002",
        bright_primary_color: "#000003",
        bright_secondary_color: "#000004"
      }
    }
  end
  let!(:organization) { described_class.new(params: params).perform }
  let(:theme) { organization.theme }

  describe "#perform" do
    it "creates a new organization and all the required data" do
      aggregate_failures do
        expect(organization.slug).to eq("tester")
      end
    end

    it "creates the organization domains" do
      aggregate_failures do
        expect(organization.slug).to eq("tester")
        expect(organization.domains.count).to eq(1)
        expect(organization.domains.exists?(domain: "tester.itsmycargo.shop")).to eq(true)
      end
    end

    it "creates a theme" do
      aggregate_failures do
        expect(theme.primary_color).to eq("#000001")
        expect(theme.secondary_color).to eq("#000002")
        expect(theme.bright_primary_color).to eq("#000003")
        expect(theme.bright_secondary_color).to eq("#000004")
      end
    end
  end
end
