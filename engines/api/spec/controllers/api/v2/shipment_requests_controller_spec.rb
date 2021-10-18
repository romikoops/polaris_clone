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
      let(:company) { FactoryBot.create(:companies_company, organization: organization) }
      let(:result) do
        FactoryBot.create(:journey_result,
          query: FactoryBot.build(:journey_query,
            client: users_client,
            company: company,
            organization: organization))
      end
      let(:commodity_infos) do
        [
          { description: "Description 1", hsCode: "1504.90.60.00", imoClass: "1" },
          { description: "Description 2", hsCode: "2504.90.60.00", imoClass: "2" }
        ]
      end
      let(:contact_attributes) do
        {
          addressLine1: "1 street", addressLine2: "2 street", addressLine3: "3 street", city: "Hamburg",
          companyName: "Foo GmBH", countryCode: "de", email: "foo@bar.com", function: "notifyee", geocodedAddress: "GEOCODE_ADDRESS_12345",
          name: "John Smith", phone: "+49123456", point: "On point", postalCode: "PC12"
        }
      end
      let(:valid_params) do
        {
          organization_id: organization.id, result_id: result.id,
          shipmentRequest: {
            withInsurance: false,
            withCustomsHandling: false, preferredVoyage: "1234", notes: "Some notes", commercialValueCents: 10, commercialValueCurrency: "EUR",
            contactsAttributes: [contact_attributes]
          },
          commodityInfos: commodity_infos
        }
      end

      let(:successful_response_data) do
        {
          "attributes" => {
            "clientId" => users_client.id, "commercialValue" => { "currency" => "EUR", "value" => 10 },
            "companyId" => company.id, "notes" => "Some notes", "preferredVoyage" => "1234", "resultId" => result.id,
            "status" => "requested", "withCustomsHandling" => false, "withInsurance" => false
          },
          "id" => kind_of(String),
          "relationships" => { "contacts" => { "data" => [{ "id" => kind_of(String), "type" => "contact" }] }, "documents" => { "data" => [] } },
          "type" => "shipmentRequest"
        }
      end

      shared_examples_for "a successful Create" do
        before { post :create, params: valid_params, as: :json }

        it "returns a 201 response" do
          expect(response).to have_http_status(:created)
        end

        it "returns the data for the shipment request, after creation was a success" do
          expect(response_data).to include(successful_response_data)
        end
      end

      it_behaves_like "a successful Create"

      context "without commodity infos" do
        let(:commodity_infos) { [] }

        it_behaves_like "a successful Create"
      end

      context "without any params" do
        let(:empty_valid_params) do
          {
            organization_id: organization.id, result_id: result.id,
            shipmentRequest: {
              withInsurance: nil,
              withCustomsHandling: nil, preferredVoyage: nil, notes: nil, commercialValueCents: nil, commercialValueCurrency: nil,
              contactsAttributes: []
            },
            commodityInfos: []
          }
        end

        it "returns a 201 response" do
          post :create, params: empty_valid_params, as: :json
          expect(response).to have_http_status(:created)
        end
      end
    end
    # rubocop:enable Naming/VariableNumber
  end
end
