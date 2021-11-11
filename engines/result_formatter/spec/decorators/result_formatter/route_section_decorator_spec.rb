# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResultFormatter::RouteSectionDecorator do
  let(:route_section) { FactoryBot.create(:journey_route_section, mode_of_transport: mode_of_transport, order: order) }
  let(:decorated_route_section) { described_class.new(route_section) }

  describe ".section_string" do
    let!(:charge_category) { FactoryBot.create(:legacy_charge_categories, code: code, organization: route_section.result.query.organization) }

    context "when the RouteSection mode_of_transport is carriage and order is 0" do
      let(:mode_of_transport) { "carriage" }
      let(:order) { 0 }
      let(:code) { "trucking_pre" }

      it "returns the charge category name for the code 'trucking_pre'" do
        expect(decorated_route_section.section_string).to eq(charge_category.name)
      end
    end

    context "when the RouteSection mode_of_transport is carriage and order is not 0" do
      let(:mode_of_transport) { "carriage" }
      let(:order) { 5 }
      let(:code) { "trucking_on" }

      it "returns the charge category name for the code 'trucking_on'" do
        expect(decorated_route_section.section_string).to eq(charge_category.name)
      end
    end

    context "when the RouteSection mode_of_transport is relay and order <= 1" do
      let(:mode_of_transport) { "relay" }
      let(:order) { 1 }
      let(:code) { "export" }

      it "returns the charge category name for the code 'export'" do
        expect(decorated_route_section.section_string).to eq(charge_category.name)
      end
    end

    context "when the RouteSection mode_of_transport is relay and order >= 1" do
      let(:mode_of_transport) { "relay" }
      let(:order) { 2 }
      let(:code) { "import" }

      it "returns the charge category name for the code 'import'" do
        expect(decorated_route_section.section_string).to eq(charge_category.name)
      end
    end

    context "when the RouteSection mode_of_transport is ocean" do
      let(:mode_of_transport) { "ocean" }
      let(:order) { 2 }
      let(:code) { "cargo" }

      it "returns the charge category name for the code 'import'" do
        expect(decorated_route_section.section_string).to eq(charge_category.name)
      end
    end
  end
end
