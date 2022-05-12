# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::Admin::ClientsController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
      FactoryBot.create(:users_membership, organization: organization, user: user)
      ::Organizations.current_id = organization.id
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:user) { FactoryBot.create(:users_user, email: "test@example.com") }

    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }

    describe "GET #index" do
      let(:params) { { organization_id: organization.id, company_id: company.id } }
      let(:company) { FactoryBot.create(:companies_company, organization: organization) }

      let(:client_a) { FactoryBot.create(:users_client, email: "abc@example.com", organization: organization) }
      let(:client_b) { FactoryBot.create(:users_client, email: "zulu@example.com", organization: organization) }

      before do
        FactoryBot.create(:companies_membership, company: company, client: client_a)
        FactoryBot.create(:companies_membership, company: company, client: client_b)
      end

      context "when no sorting applied" do
        it "returns clients", :aggregate_failures do
          get :index, params: params, as: :json
          expect(response).to be_successful
          expect(response_data).not_to be_empty
        end
      end

      context "when sorting by email" do
        it "returns clients sorted by email desc", :aggregate_failures do
          get :index, params: params.merge(sortBy: "email", direction: "desc"), as: :json
          expect(response_data.pluck("id")).to eq([client_b.id, client_a.id])
        end

        it "returns clients sorted by email asc", :aggregate_failures do
          get :index, params: params.merge(sortBy: "email", direction: "asc"), as: :json
          expect(response_data.pluck("id")).to eq([client_a.id, client_b.id])
        end
      end

      context "when paginating" do
        it "returns one client per page (Page 1)", :aggregate_failures do
          get :index, params: params.merge(sortBy: "email", direction: "desc", page: 1, perPage: 1), as: :json
          expect(response_data.pluck("id")).to eq([client_b.id])
        end

        it "returns one client per page (Page 2)", :aggregate_failures do
          get :index, params: params.merge(sortBy: "email", direction: "desc", page: 2, perPage: 1), as: :json
          expect(response_data.pluck("id")).to eq([client_a.id])
        end
      end
    end
  end
end
