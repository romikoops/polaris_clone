# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ShipmentRequestsController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = "Bearer #{access_token.token}"
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:shipment_request_id) { "SR12345" }

    describe "GET #show" do
      it "returns a 200 response" do
        get :show, params: { id: shipment_request_id, organization_id: organization.id }, as: :json
        expect(response).to have_http_status(:ok)
      end

      it "returns data for the shipment request" do
        get :show, params: { id: "SR12345", organization_id: organization.id }, as: :json
        expect(response_data).to include("attributes" => { "preferredVoyage" => "FOO" })
      end
    end

    describe "POST #create" do
      it "returns a 201 response" do
        post :create, params: valid_params, as: :json
        expect(response).to have_http_status(:ok)
      end

      it "returns the data for the shipment request, after creation was a success" do
        post :create, params: valid_params, as: :json
        expect(response_data).to include("attributes" => { "preferredVoyage" => "FOO" })
      end

      it "returns a 422 response, when none of the shipment request params are not present" do
        post :create, params: { organization_id: organization.id, id: shipment_request_id }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns a suitable message, when none of the shipment request params are present" do
        post :create, params: { organization_id: organization.id, id: shipment_request_id, shipment_request: { foo: "bar" } }, as: :json
        expect(response_error).to eq(
          "Please provide at least one param of result_id, additional_requirements, "\
          "customs, insurance, commercial_value, contact"
        )
      end

      def valid_params
        {
          id: "SR12345", organization_id: organization.id, result_id: "RESULT_ID_12345",
          additional_requirements: "Nothing here", customs: true, insurance: true,
          commercial_value: "100", contact: { name: "John", phone: "12345", email: "foo@bar.com", additional_information: "some text" }
        }
      end
    end
  end
end
