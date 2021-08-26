# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::CompaniesController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let!(:companies_company) { FactoryBot.create(:companies_company, organization: organization, email: "foo@bar.com", name: "company1", phone: "112233", vat_number: "DE-VATNUMBER1") }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }

    describe "GET #show" do
      it "returns a 200 OK response" do
        get :show, params: { organization_id: organization.id, id: companies_company.id }, as: :json
        expect(response).to have_http_status(:ok)
      end

      it "returns data about the requested company" do
        get :show, params: { organization_id: organization.id, id: companies_company.id }, as: :json
        expect(response_data).to include("attributes" => {
          "email" => "foo@bar.com", "name" => "company1", "paymentTerms" => "Some quotation payment terms",
          "phone" => "112233", "vatNumber" => "DE-VATNUMBER1"
        }, "id" => companies_company.id, "type" => "company")
      end

      it "returns a 404 response, when the requested company does not exist" do
        get :show, params: { organization_id: organization.id, id: "non-existent-id" }, as: :json
        expect(response_json).to include({ "status" => "not_found", "code" => 404 })
      end
    end

    describe "PUT #update" do
      it "returns a 204 updated response" do
        put :update, params: { organization_id: organization.id, id: companies_company.id, company: { paymentTerms: "some payment terms example" } }, as: :json
        expect(response).to have_http_status(:ok)
      end

      it "updates the company with the given request params" do
        put :update, params: request_params, as: :json
        expect(response_data).to include("attributes" => {
          "email" => "awesome@company.com", "name" => "Awesome company", "paymentTerms" => "some payment terms example",
          "phone" => "554433", "vatNumber" => "VAT12345"
        }, "id" => companies_company.id, "type" => "company")
      end

      it "returns a 422 unprocessable_entity, when none of the company params are present" do
        put :update, params: { organization_id: organization.id, id: companies_company.id, company: { foo: "bar" } }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns a suitable message, when none of the company params are present" do
        put :update, params: { organization_id: organization.id, id: companies_company.id, company: { foo: "bar" } }, as: :json
        expect(response_error).to eq("Please provide at least one param of email, name, paymentTerms, phone, or vatNumber")
      end

      def request_params
        {
          organization_id: organization.id,
          id: companies_company.id,
          company: {
            email: "awesome@company.com", name: "Awesome company",
            paymentTerms: "some payment terms example", phone: 554_433, vatNumber: "VAT12345"
          }
        }
      end
    end
  end
end
