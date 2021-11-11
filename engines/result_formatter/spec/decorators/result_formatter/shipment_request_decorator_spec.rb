# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResultFormatter::ShipmentRequestDecorator do
  include_context "journey_pdf_setup"
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:client) do
    FactoryBot.create(:users_client, organization: organization)
  end
  let(:shipment_request) do
    FactoryBot.create(:journey_shipment_request,
      result: result,
      client: client,
      company: query.company,
      commercial_value_currency: "USD",
      commercial_value_cents: 1000
    )
  end
  let(:decorated_shipment_request) { described_class.decorate(shipment_request) }

  before do
    FactoryBot.create(:companies_membership, company: query.company, client: client)
    ::Organizations.current_id = organization.id
  end

  describe "#commercial_value_format" do
    it "the formatted commercial value" do
      expect(decorated_shipment_request.commercial_value_format).to eq("USD 10.00")
    end
  end

  describe "#total_format" do
    it "the formatted total of the Result" do
      expect(decorated_shipment_request.total_format).to eq("EUR 180.00")
    end
  end
end
