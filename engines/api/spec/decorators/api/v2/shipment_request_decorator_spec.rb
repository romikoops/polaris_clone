# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::ShipmentRequestDecorator do
  include_context "journey_pdf_setup"
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:client) do
    FactoryBot.create(:users_client, organization: organization)
  end
  let(:shipment_request) do
    FactoryBot.create(:journey_shipment_request,
      result: result,
      client: client,
      company: query.company)
  end
  let(:decorated_shipment_request) { described_class.decorate(shipment_request) }

  before do
    FactoryBot.create(:companies_membership, company: query.company, client: client)
    ::Organizations.current_id = organization.id
  end

  describe "#status" do
    it "returns the humanized status" do
      expect(decorated_shipment_request.status).to eq("Requested")
    end
  end

  describe "#origin_hub" do
    it "returns the name of the origin hub" do
      expect(decorated_shipment_request.origin_hub).to eq("Hamburg")
    end
  end

  describe "#destination_hub" do
    it "returns the name of the destination hub" do
      expect(decorated_shipment_request.destination_hub).to eq("Shanghai")
    end
  end

  describe "#origin_pickup" do
    it "returns the address where the cargo will be collected" do
      expect(decorated_shipment_request.origin_pickup).to eq("438 80 Landvetter, Sweden")
    end

    context "when there is no pickup" do
      let(:route_sections) { [freight_section] }

      it "returns nil when there is no pre-carriage" do
        expect(decorated_shipment_request.origin_pickup).to be_nil
      end
    end
  end

  describe "#destination_dropoff" do
    it "returns the address where the cargo will be dropped off" do
      expect(decorated_shipment_request.destination_dropoff).to eq("88 Henan Middle Road, Shanghai")
    end

    context "when there is no dropoff" do
      let(:route_sections) { [freight_section] }

      it "returns nil when there is no on-carriage" do
        expect(decorated_shipment_request.destination_dropoff).to be_nil
      end
    end
  end
end
