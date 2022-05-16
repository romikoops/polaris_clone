# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::Admin::CompaniesController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_user).tap { |users_user| FactoryBot.create(:users_membership, organization: organization, user: users_user) } }
    let!(:companies_company) { FactoryBot.create(:companies_company, organization: organization, email: "foo@bar.com", name: "company_one", phone: "112233", vat_number: "DE-VATNUMBER1") }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }

    shared_examples_for "unauthorized for non users user" do
      it "returns unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "GET #show" do
      let(:expected_result) do
        { "id" => companies_company.id,
          "type" => "company",
          "attributes" =>
         { "id" => companies_company.id,
           "email" => "foo@bar.com",
           "name" => "company_one",
           "paymentTerms" => "Some quotation payment terms",
           "phone" => "112233",
           "vatNumber" => "DE-VATNUMBER1",
           "contactPersonName" => nil,
           "contactPhone" => nil,
           "contactEmail" => nil,
           "registrationNumber" => nil,
           "streetNumber" => nil,
           "street" => nil,
           "city" => nil,
           "postalCode" => nil,
           "country" => nil,
           "lastActivityAt" => nil } }
      end

      it "returns a 200 OK response" do
        get :show, params: { organization_id: organization.id, id: companies_company.id }, as: :json
        expect(response).to have_http_status(:ok)
      end

      it "returns data about the requested company" do
        get :show, params: { organization_id: organization.id, id: companies_company.id }, as: :json

        expect(response_data).to include(expected_result)
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
      let(:params) { { organization_id: organization.id } }
      let!(:company_a) { FactoryBot.create(:companies_company, name: "abc cargo", country: factory_country_from_code(code: "cn"), organization: organization) }
      let!(:company_c) { FactoryBot.create(:companies_company, name: "core cargo", country: factory_country_from_code(code: "uk"), organization: organization) }
      let!(:company_d) { FactoryBot.create(:companies_company, name: "delta cargo", organization: organization) }

      it "returns all the companies for the organisation and ids matching the companies ids" do
        get :index, params: params
        expect(response_data.pluck("id")).to match_array(Companies::Company.where(organization: organization).ids)
      end

      it "with pagination params, asserts that a total of two companies were returned" do
        get :index, params: { organization_id: organization.id, perPage: 2 }
        expect(response_data.length).to eq(2)
      end

      context "with invalid searchBy" do
        let(:params) { { organization_id: organization.id, searchBy: "origin", searchQuery: "Germany" } }

        before { get :index, params: params }

        it "returns unprocessable entity" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when searchBy is specified but searchQuery is missing" do
        let(:params) { { organization_id: organization.id, searchBy: "name" } }

        before { get :index, params: params }

        it "returns unprocessable entity" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when beforeDate is not specified but afterDate is present" do
        let(:params) { { organization_id: organization.id, afterDate: 3.days.ago.to_s } }

        before do
          FactoryBot.create(:journey_query, company: company_d, created_at: 1.week.ago, updated_at: 1.week.ago, organization: organization)
          FactoryBot.create(:journey_query, company: company_a, created_at: 2.days.ago, updated_at: 2.days.ago, organization: organization)
          FactoryBot.create(:journey_query, company: company_c, created_at: Time.zone.yesterday, updated_at: Time.zone.yesterday, organization: organization)
          get :index, params: params
        end

        it "returns 200 Success" do
          expect(response).to have_http_status(:success)
        end

        it "returns all companies within the last 3 days" do
          expect(response_data.pluck("id")).to match_array([company_a.id, company_c.id])
        end
      end

      context "when beforeDate is specified but afterDate is not present" do
        let(:params) { { organization_id: organization.id, beforeDate: 3.days.ago.to_s } }

        before do
          FactoryBot.create(:journey_query, company: company_d, created_at: 1.week.ago, updated_at: 1.week.ago, organization: organization)
          FactoryBot.create(:journey_query, company: company_a, created_at: 2.days.ago, updated_at: 2.days.ago, organization: organization)
          FactoryBot.create(:journey_query, company: company_c, created_at: Time.zone.yesterday, updated_at: Time.zone.yesterday, organization: organization)
          get :index, params: params
        end

        it "returns 200 Success" do
          expect(response).to have_http_status(:success)
        end

        it "returns all companies from epoch time until 3 days ago" do
          expect(response_data.pluck("id")).to match_array([company_d.id])
        end
      end

      context "when current user is not users user" do
        let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }

        before { get :index, params: params }

        it_behaves_like "unauthorized for non users user"
      end
    end

    describe "PUT #update" do
      let(:expected_result) do
        {
          "id" => companies_company.id,
          "type" => "company",
          "attributes" =>
           { "id" => companies_company.id,
             "email" => "awesome@company.com",
             "name" => "Awesome company",
             "paymentTerms" => "some payment terms example",
             "phone" => "554433",
             "vatNumber" => "VAT12345",
             "contactPersonName" => nil,
             "contactPhone" => nil,
             "contactEmail" => nil,
             "registrationNumber" => nil,
             "streetNumber" => nil,
             "street" => nil,
             "city" => nil,
             "postalCode" => nil,
             "country" => nil,
             "lastActivityAt" => nil }
        }
      end

      it "returns a 204 updated response" do
        put :update, params: { organization_id: organization.id, id: companies_company.id, company: { paymentTerms: "some payment terms example" } }, as: :json
        expect(response).to have_http_status(:ok)
      end

      it "updates the company with the given request params" do
        put :update, params: request_params, as: :json

        expect(response_data).to include(expected_result)
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

    describe "DELETE #destroy" do
      let(:company) { FactoryBot.create(:companies_company, organization: organization) }
      let(:params) { { organization_id: organization.id, id: company.id } }

      context "when company has shipment requests with status `completed`" do
        before { FactoryBot.create(:journey_shipment_request, company_id: company.id, status: "completed") }

        it "returns 200 OK" do
          delete :destroy, params: params
          expect(response).to have_http_status(:success)
        end
      end

      context "when company is not found" do
        let(:params) { { organization_id: organization.id, id: "random_id" } }

        it "returns 404  Not found" do
          delete :destroy, params: params
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when company has shipment requests status as `requested`" do
        before { FactoryBot.create(:journey_shipment_request, company_id: company.id, status: "requested") }

        it "raises `HasOngoingShipments` exception" do
          expect { delete :destroy, params: params }.to raise_error(Companies::CompanyServices::HasOngoingShipments)
        end
      end

      context "when company has shipment requests status as `in_progress`" do
        before { FactoryBot.create(:journey_shipment_request, company_id: company.id, status: "in_progress") }

        it "raises `HasOngoingShipments` exception" do
          expect { delete :destroy, params: params }.to raise_error(Companies::CompanyServices::HasOngoingShipments)
        end
      end

      context "when current user is not users user" do
        let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }

        before { delete :destroy, params: params }

        it_behaves_like "unauthorized for non users user"
      end
    end
  end
end
