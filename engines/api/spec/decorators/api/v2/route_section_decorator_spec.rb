# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::RouteSectionDecorator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:decorated_route_section) { described_class.new(route_section, context: { scope: Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access }) }
  let!(:routing_carrier) { FactoryBot.create(:routing_carrier, with_logo: with_logo) }
  let(:with_logo) { true }
  let(:route_section) { FactoryBot.build(:journey_route_section, carrier: routing_carrier.name) }

  before do
    Organizations.current_id = organization.id
  end

  describe "#origin" do
    let(:origin) { decorated_route_section.origin }
    let(:expected_result) do
      {
        "locode" => route_section.from.locode,
        "terminal" => route_section.from.terminal,
        "city" => route_section.from.city,
        "coordinates" => route_section.from.coordinates,
        "address" => route_section.from.name
      }
    end

    it "returns the legacy response format for the index list" do
      expect(origin).to eq(expected_result)
    end
  end

  describe ".carrier_logo" do
    context "with logo attached" do
      it "returns the url for accessing the logo of the freight carrier" do
        expect(decorated_route_section.carrier_logo).to include("test-image.jpg")
      end
    end

    context "without logo attached" do
      let(:with_logo) { false }

      it "returns the url for accessing the logo of the freight carrier" do
        expect(decorated_route_section.carrier_logo).to be_nil
      end
    end
  end
end
