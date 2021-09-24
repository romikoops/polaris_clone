# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ShipmentRequestsController, type: :controller do
    # rubocop:disable Naming/VariableNumber
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = "Bearer #{access_token.token}"
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:users_client) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: users_client.id, scopes: "public") }

    describe "GET #show" do
      let(:shipment_request) { FactoryBot.create(:journey_shipment_request) }

      it "returns a 200 response" do
        get :show, params: { id: shipment_request.id, organization_id: organization.id }, as: :json
        expect(response).to have_http_status(:ok)
      end

      it "returns data for the shipment request" do
        get :show, params: { id: shipment_request.id, organization_id: organization.id }, as: :json
        expect(response_data).to include(successful_response_data)
      end

      it "returns a 404 response, when the shipment request does not exist" do
        get :show, params: { id: "non-existent-id", organization_id: organization.id }, as: :json
        expect(response).to have_http_status(:not_found)
      end

      def successful_response_data
        {
          "attributes" => {
            "clientId" => shipment_request.client_id, "commercialValue" => { "currency" => "eur", "value" => 10 },
            "companyId" => shipment_request.company_id, "notes" => "", "preferredVoyage" => "1234", "resultId" => shipment_request.result_id,
            "status" => "requested", "withCustomsHandling" => false, "withInsurance" => false
          }, "id" => shipment_request.id, "relationships" => {
            "contacts" => { "data" => [{ "id" => shipment_request.contacts.first.id, "type" => "contact" }] },
            "documents" => { "data" => [{ "id" => shipment_request.documents.first.id, "type" => "document" }] }
          }
        }
      end
    end

    describe "POST #create" do
      let(:company) { FactoryBot.create(:companies_company) }
      let(:result) { FactoryBot.create(:journey_result) }

      it "returns a 201 response" do
        post :create, params: valid_params, as: :json
        expect(response).to have_http_status(:created)
      end

      it "returns the data for the shipment request, after creation was a success" do
        post :create, params: valid_params, as: :json
        expect(response_data).to include(successful_response_data)
      end

      it "returns a 422 response, when none of the shipment request params are not present" do
        post :create, params: { organization_id: organization.id, shipment_request: { foo: "bar" } }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns a suitable message, when none of the shipment request params are present" do
        post :create, params: { organization_id: organization.id, shipment_request: { foo: "bar" } }, as: :json
        expect(response_error).to eq(
          "Please provide params of result_id, company_id, client_id, with_insurance, with_customs_handling, "\
          "status, preferred_voyage, notes, commercial_value_cents, commercial_value_currency, contacts_attributes"
        )
      end

      def valid_params
        {
          organization_id: organization.id, result_id: result.id, company_id: company.id, client_id: users_client.id, with_insurance: false,
          with_customs_handling: false, status: "requested", preferred_voyage: "1234", notes: "Some notes", commercial_value_cents: 10, commercial_value_currency: :eur,
          contacts_attributes: [{
            address_line_1: "1 street", address_line_2: "2 street", address_line_3: "3 street", city: "Hamburg",
            company_name: "Foo GmBH", country_code: "de", email: "foo@bar.com", function: "notifyee", geocoded_address: "GEOCODE_ADDRESS_12345",
            name: "John Smith", phone: "+49123456", point: "On point", postal_code: "PC12"
          }],
          commodity_infos: [
            { description: "Description 1", hs_code: "1504.90.60.00", imo_class: "1" },
            { description: "Description 2", hs_code: "2504.90.60.00", imo_class: "2" }
          ]
        }
      end

      def successful_response_data
        {
          "attributes" => {
            "clientId" => users_client.id, "commercialValue" => { "currency" => "eur", "value" => 10 },
            "companyId" => company.id, "notes" => "Some notes", "preferredVoyage" => "1234", "resultId" => result.id,
            "status" => "requested", "withCustomsHandling" => false, "withInsurance" => false
          },
          "id" => kind_of(String),
          "relationships" => { "contacts" => { "data" => [{ "id" => kind_of(String), "type" => "contact" }] }, "documents" => { "data" => [] } },
          "type" => "shipmentRequest"
        }
      end
    end
    # rubocop:enable Naming/VariableNumber
  end
end
