# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::CompaniesController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_user, organization_id: organization.id) }
    let!(:companies_company) { FactoryBot.create(:companies_company, organization: organization, email: "foo@bar.com", name: "company1", phone: "112233", vat_number: "DE-VATNUMBER1") }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }

    shared_examples_for "unauthorized for non users user" do
      it "returns unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "GET #show" do
      it "returns a 200 OK response" do
        get :show, params: { organization_id: organization.id, id: companies_company.id }, as: :json
        expect(response).to have_http_status(:ok)
      end

      it "returns data about the requested company" do
        get :show, params: { organization_id: organization.id, id: companies_company.id }, as: :json
        expect(response_data).to include("attributes" => {
          "contactEmail" => nil, "contactPersonName" => nil, "contactPhone" => nil, "registrationNumber" => nil, "email" => "foo@bar.com", "name" => "company1",
          "paymentTerms" => "Some quotation payment terms", "phone" => "112233", "vatNumber" => "DE-VATNUMBER1", "id" => companies_company.id
        }, "id" => companies_company.id, "type" => "company")
      end

      it "returns a 404 response, when the requested company does not exist" do
        get :show, params: { organization_id: organization.id, id: "non-existent-id" }, as: :json
        expect(response_json).to include({ "status" => "not_found", "code" => 404 })
      end

      context "when current user is not users user" do
        let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }

        before { get :show, params: { organization_id: organization.id, id: companies_company.id }, as: :json }

        it_behaves_like "unauthorized for non users user"
      end
    end

    describe "GET #index" do
      before { FactoryBot.create_list(:companies_company, 5, organization: organization) }

      let(:params) { { organization_id: organization.id } }

      context "without pagination params" do
        before { get :index, params: params }

        it "returns all the companies for the organisation and ids matching the companies ids" do
          expect(response_data.pluck("id")).to match_array(Companies::Company.all.ids)
        end
      end

      context "with pagination params" do
        it "asserts that a total of two companies were returned" do
          get :index, params: { organization_id: organization.id, perPage: 2 }
          expect(response_data.length).to eq(2)
        end
      end

      context "when current user is not users user" do
        let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }

        before { get :index, params: params }

        it_behaves_like "unauthorized for non users user"
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
          "contactEmail" => nil, "contactPersonName" => nil, "contactPhone" => nil, "registrationNumber" => nil, "email" => "awesome@company.com", "name" => "Awesome company",
          "paymentTerms" => "some payment terms example", "phone" => "554433", "vatNumber" => "VAT12345", "id" => companies_company.id
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

      context "when current user is not users user" do
        let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }

        before { put :update, params: request_params, as: :json }

        it_behaves_like "unauthorized for non users user"
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

    describe "POST #create" do
      let(:create_params) do
        {
          name: "test-company",
          email: "company@test-company.com",
          phone: "1234567890",
          paymentTerms: "some payment terms example",
          vatNumber: "vat12",
          contactPersonName: "John Doe",
          contactPhone: "9876543210",
          contactEmail: "contact@test-company.com",
          registrationNumber: "reg987"
        }
      end

      context "with valid params" do
        it "returns 201 `created` after the company was created" do
          post :create, params: { organization_id: organization.id, company: create_params }
          expect(response).to have_http_status(:created)
        end

        context "with address" do
          let(:company_address) { FactoryBot.create(:gothenburg_address) }

          before do
            allow(Legacy::Address).to receive(:geocoded_address) { company_address }
            post :create, params: { organization_id: organization.id, company: create_params.merge(address: { streetNumber: 1, street: "Test" }) }
          end

          it "returns 201 `created` after the company was created" do
            expect(response).to have_http_status(:created)
          end

          it "creates a new company company and associates specified address" do
            expect(Companies::Company.find_by(name: create_params[:name]).address).to eq(company_address)
          end
        end
      end

      context "when name or email is missing in params" do
        it "fails with 400 bad request when email is missing" do
          post :create, params: { organization_id: organization.id, company: create_params.tap { |params| params.delete(:email) } }
          expect(response).to have_http_status(:bad_request)
        end

        it "fails with 400 bad request when name is missing" do
          post :create, params: { organization_id: organization.id, company: create_params.tap { |params| params.delete(:name) } }
          expect(response).to have_http_status(:bad_request)
        end
      end

      context "when company already exists" do
        before { post :create, params: { organization_id: organization.id, company: create_params } }

        it "fails with 422 unprocessable_entity" do
          post :create, params: { organization_id: organization.id, company: create_params }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when current user is not users user" do
        let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }

        before { post :create, params: { organization_id: organization.id, company: create_params } }

        it_behaves_like "unauthorized for non users user"
      end
    end
  end
end
