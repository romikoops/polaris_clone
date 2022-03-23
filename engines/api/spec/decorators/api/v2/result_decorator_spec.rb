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

  describe "#total" do
    context "when the query has no client id and creator id attached to it" do
      let(:query) { FactoryBot.create(:journey_query, organization: organization, creator_id: nil, client_id: nil) }

      it "returns nil" do
        expect(decorated_result.total).to be_nil
      end
    end

    it "returns when results with the parent method when the result's query has a client attached to it" do
      expect(decorated_result.total).to eq(Money.from_amount(108, "EUR"))
    end
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
    it "returns zero when the transshipment is blank" do
      expect(decorated_result.number_of_stops).to eq(0)
    end

    context "with transshipment" do
      let(:transshipment) { "ZACPT" }

      it "returns 1 as the number of stops when transsshipment is present" do
        expect(decorated_result.number_of_stops).to eq(1)
      end
    end
  end

  describe "#cargo_delivery_date" do
    it "returns nil when the route section transit time is blank" do
      expect(decorated_result.cargo_delivery_date).to be_nil
    end

    context "when the main route section has transit time" do
      let(:main_freight_section) do
        FactoryBot.build(:journey_route_section,
          order: 3,
          mode_of_transport: "ocean",
          transshipment: transshipment,
          transit_time: 5,
          carrier: routing_carrier.name)
      end

      it "returns sum of all transit times stored on the RouteSections where missing transit times are assumed to be 0" do
        expect(decorated_result.cargo_delivery_date).to eq(query.cargo_ready_date + 5.days)
      end
    end
  end
end
