# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::ShipmentRequestCreationService do
  # rubocop:disable Naming/VariableNumber
  before do
    Organizations.current_id = organization.id
  end

  let(:result) { FactoryBot.create(:journey_result) }
  let(:company) { FactoryBot.create(:companies_company, organization: organization) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:users_client) { FactoryBot.create(:users_client, organization: organization) }

  describe "#perform" do
    it "returns a Journey::ShipmentRequest instance" do
      expect(perform).to be_a(Journey::ShipmentRequest)
    end

    it "verifies that a Journey::ShipmentRequest was persisted successfully" do
      expect { perform }.to change { Journey::ShipmentRequest.count }.from(0).to(1)
    end

    it "verifies that the two Journey::Contact objects are attached to the journey shipment request instance" do
      shipment_request = perform
      contacts = Journey::Contact.where(shipment_request_id: shipment_request.id)
      expect(contacts).to match_array([
        have_attributes(shipment_request_id: shipment_request.id), have_attributes(shipment_request_id: shipment_request.id)
      ])
    end

    it "verifies that 2 commodity info objects were persisted" do
      expect { perform }.to change { Journey::CommodityInfo.count }.from(0).to(2)
    end

    def perform
      Api::ShipmentRequestCreationService.new(
        shipment_request_params: shipment_request_params,
        commodity_info_params: commodity_info_params
      ).perform
    end

    def shipment_request_params
      {
        result_id: result.id, company_id: company.id, client_id: users_client.id,
        with_insurance: false, with_customs_handling: false, status: "requested",
        preferred_voyage: "1234", notes: "some notes", commercial_value_cents: 10,
        commercial_value_currency: :eur, contacts_attributes: contacts_attributes
      }
    end

    def commodity_info_params
      [
        { description: "Description 1", hs_code: "1504.90.60.00", imo_class: "1" },
        { description: "Description 2", hs_code: "2504.90.60.00", imo_class: "2" }
      ]
    end

    def contacts_attributes
      [
        {
          address_line_1: "1 street", address_line_2: "2 street", address_line_3: "3 street", city: "Hamburg",
          company_name: "Foo GmBH", country_code: "de", email: "foo@bar.com", function: "notifyee", geocoded_address: "GEOCODE_ADDRESS_12345",
          name: "John Smith", phone: "+49123456", point: "On point", postal_code: "PC12"
        },
        {
          address_line_1: "4 street", address_line_2: "5 street", address_line_3: "6 street", city: "Berlin",
          company_name: "Foo GmBH", country_code: "de", email: "bar@baz.com", function: "notifyee", geocoded_address: "GEOCODE_ADDRESS_56789",
          name: "David Smith", phone: "+497891011", point: "On point again", postal_code: "PC20"
        }
      ]
    end
  end
  # rubocop:enable Naming/VariableNumber
end
