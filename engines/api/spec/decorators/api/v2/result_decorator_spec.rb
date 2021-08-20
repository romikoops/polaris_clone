# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::ResultDecorator do
  let!(:result) { FactoryBot.create(:journey_result, sections: 0, route_sections: route_sections, query: query) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:decorated_result) { described_class.new(result, context: { scope: Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access }) }
  let(:query) { FactoryBot.create(:journey_query, organization: organization) }
  let!(:routing_carrier) { FactoryBot.create(:routing_carrier, with_logo: with_logo) }
  let(:with_logo) { true }
  let(:route_sections) do
    [
      FactoryBot.build(:journey_route_section, order: 1, mode_of_transport: "carriage"),
      FactoryBot.build(:journey_route_section, order: 2, mode_of_transport: "relay"),
      main_freight_section
    ]
  end
  let(:main_freight_section) do
    FactoryBot.build(:journey_route_section,
      order: 3,
      mode_of_transport: "ocean",
      transshipment: transshipment,
      carrier: routing_carrier.name)
  end
  let(:transshipment) { nil }

  before do
    Organizations.current_id = organization.id
  end

  describe ".carrier_logo" do
    context "with logo attached" do
      it "returns the url for accessing the logo of the freight carrier" do
        expect(decorated_result.carrier_logo).to include("test-image.jpg")
      end
    end

    context "without logo attached" do
      let(:with_logo) { false }

      it "returns the url for accessing the logo of the freight carrier" do
        expect(decorated_result.carrier_logo).to be_nil
      end
    end
  end

  describe ".routing_carrier" do
    it "returns the Routing::Carrier based off the main freight Section" do
      expect(decorated_result.routing_carrier).to eq(routing_carrier)
    end
  end

  describe ".number_of_stops" do
    it "returns the Relay count as the number of stops " do
      expect(decorated_result.number_of_stops).to eq(1)
    end

    context "with transshipment" do
      let(:transshipment) { "ZACPT" }

      it "returns the Relay count + 1 for the transshipment as the number of stops " do
        expect(decorated_result.number_of_stops).to eq(2)
      end
    end

    context "with transshipment as 'DIRECT'" do
      let(:transshipment) { "DIRECT" }

      it "returns the Relay count + 1 for the transshipment as the number of stops " do
        expect(decorated_result.number_of_stops).to eq(1)
      end
    end
  end
end
