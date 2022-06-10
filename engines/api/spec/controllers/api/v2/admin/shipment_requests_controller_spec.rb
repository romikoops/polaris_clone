# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::Admin::ShipmentRequestsController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:users_client) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:user) { FactoryBot.create(:users_user).tap { |users_user| FactoryBot.create(:users_membership, organization: organization, user: users_user) } }
    let!(:companies_company) { FactoryBot.create(:companies_company, organization: organization, email: "foo@bar.com", name: "company_one", phone: "112233", vat_number: "DE-VATNUMBER1") }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }

    describe "GET #index" do
      let(:params) { { organization_id: organization.id, company_id: companies_company.id } }

      context "when sorting" do
        let!(:shipment_request_a_id) do
          FactoryBot.create(:journey_shipment_request,
            created_at: 2.hours.ago,
            company: companies_company,
            client: users_client).id
        end
        let!(:shipment_request_b_id) do
          FactoryBot.create(:journey_shipment_request,
            created_at: 5.hours.ago,
            company: companies_company,
            client: users_client).id
        end

        context "when no sorting applied" do
          it "returns the shipment requests", :aggregate_failures do
            get :index, params: params, as: :json
            expect(response_data.pluck("id")).to match_array([shipment_request_a_id, shipment_request_b_id])
          end
        end

        context "when sorting by created_at" do
          it "returns the Shipment Requests sorted by created_at desc", :aggregate_failures do
            get :index, params: params.merge(sortBy: "created_at", direction: "desc"), as: :json
            expect(response_data.pluck("id")).to eq([shipment_request_a_id, shipment_request_b_id])
          end

          it "returns the Shipment Requests sorted by created_at asc", :aggregate_failures do
            get :index, params: params.merge(sortBy: "created_at", direction: "asc"), as: :json
            expect(response_data.pluck("id")).to eq([shipment_request_b_id, shipment_request_a_id])
          end
        end

        context "when paginating" do
          it "returns one Shipment Request per page (Page 1)", :aggregate_failures do
            get :index, params: params.merge(sortBy: "created_at", direction: "desc", page: 1, perPage: 1), as: :json
            expect(response_data.pluck("id")).to eq([shipment_request_a_id])
          end

          it "returns one Query per page (Page 2)", :aggregate_failures do
            get :index, params: params.merge(sortBy: "created_at", direction: "desc", page: 2, perPage: 1), as: :json
            expect(response_data.pluck("id")).to eq([shipment_request_b_id])
          end
        end
      end
    end
  end
end
