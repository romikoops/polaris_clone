# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::Admin::QueriesController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:users_client) { FactoryBot.create(:api_client, organization_id: organization.id) }
    let(:user) { FactoryBot.create(:users_user).tap { |users_user| FactoryBot.create(:users_membership, organization: organization, user: users_user) } }
    let!(:companies_company) { FactoryBot.create(:companies_company, organization: organization, email: "foo@bar.com", name: "company_one", phone: "112233", vat_number: "DE-VATNUMBER1") }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }

    describe "GET #index" do
      let(:params) { { organization_id: organization.id, company_id: companies_company.id } }

      context "when sorting" do
        let!(:query_a) do
          FactoryBot.create(:api_query,
            origin: "aaaaa",
            destination: "aaaaa",
            organization: organization,
            cargo_ready_date: 3.days.from_now,
            created_at: 2.hours.ago,
            client: users_client,
            company: companies_company,
            results: [FactoryBot.build(:journey_result)])
        end
        let!(:query_b) do
          FactoryBot.create(:api_query,
            origin: "bbbbb",
            destination: "bbbbb",
            organization: organization,
            cargo_ready_date: 2.days.from_now,
            created_at: 5.hours.ago,
            client: users_client,
            company: companies_company,
            billable: false,
            results: [FactoryBot.build(:journey_result)])
        end

        context "when no sorting applied" do
          it "returns the shipment requests", :aggregate_failures do
            get :index, params: params, as: :json
            expect(response_data.pluck("id")).to match_array([query_a.id, query_b.id])
          end
        end

        context "when sorting by created_at" do
          it "returns the Queries sorted by created_at desc", :aggregate_failures do
            get :index, params: params.merge(sortBy: "created_at", direction: "desc"), as: :json
            expect(response_data.pluck("id")).to eq([query_a.id, query_b.id])
          end

          it "returns the Queries sorted by created_at asc", :aggregate_failures do
            get :index, params: params.merge(sortBy: "created_at", direction: "asc"), as: :json
            expect(response_data.pluck("id")).to eq([query_b.id, query_a.id])
          end
        end

        context "when sorting by origin" do
          it "returns the Queries sorted by origin desc", :aggregate_failures do
            get :index, params: params.merge(sortBy: "origin", direction: "desc"), as: :json
            expect(response_data.pluck("id")).to eq([query_b.id, query_a.id])
          end

          it "returns the Queries sorted by origin asc", :aggregate_failures do
            get :index, params: params.merge(sortBy: "origin", direction: "asc"), as: :json
            expect(response_data.pluck("id")).to eq([query_a.id, query_b.id])
          end
        end

        context "when sorting by destination" do
          it "returns the Queries sorted by destination desc", :aggregate_failures do
            get :index, params: params.merge(sortBy: "destination", direction: "desc"), as: :json
            expect(response_data.pluck("id")).to eq([query_b.id, query_a.id])
          end

          it "returns the Queries sorted by destination asc", :aggregate_failures do
            get :index, params: params.merge(sortBy: "destination", direction: "asc"), as: :json
            expect(response_data.pluck("id")).to eq([query_a.id, query_b.id])
          end
        end

        context "when sorting by cargo_ready_date" do
          it "returns the Queries sorted by cargo_ready_date desc", :aggregate_failures do
            get :index, params: params.merge(sortBy: "cargo_ready_date", direction: "desc"), as: :json
            expect(response_data.pluck("id")).to eq([query_a.id, query_b.id])
          end

          it "returns the Queries sorted by cargo_ready_date asc", :aggregate_failures do
            get :index, params: params.merge(sortBy: "cargo_ready_date", direction: "asc"), as: :json
            expect(response_data.pluck("id")).to eq([query_b.id, query_a.id])
          end
        end

        context "when paginating" do
          it "returns one Query per page (Page 1)", :aggregate_failures do
            get :index, params: params.merge(page: 1, perPage: 1), as: :json
            expect(response_data.pluck("id")).to eq([query_a.id])
          end

          it "returns one Query per page (Page 2)", :aggregate_failures do
            get :index, params: params.merge(page: 2, perPage: 1), as: :json
            expect(response_data.pluck("id")).to eq([query_b.id])
          end
        end
      end

      context "when searching" do
        let!(:query) { FactoryBot.create(:api_query, company: companies_company, result_count: 1, client: users_client, organization: organization) }

        before do
          FactoryBot.create_list(:api_query, 2, company: companies_company, result_count: 1, organization: organization, client: users_client)
          Organizations.current_id = organization.id
          get :index, params: params.merge(searchBy: search_by, searchQuery: search_query), as: :json
        end

        shared_examples_for "finding the right Query" do
          it "finds the correct Query" do
            expect(response_data.pluck("id")).to match_array([query.id])
          end
        end

        context "when search_by is invalid" do
          let(:search_query) { "aaaa" }
          let(:search_by) { "aaaa" }

          it "raises and error when the param is invalid" do
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context "when searching by reference" do
          let!(:line_item_set) { FactoryBot.create(:journey_line_item_set, result: query.results.first) }
          let(:search_query) { line_item_set.reference }
          let(:search_by) { "reference" }

          it_behaves_like "finding the right Query"
        end

        context "when searching by origin" do
          let!(:query) { FactoryBot.create(:api_query, origin: "Cape Town", company: companies_company, client: users_client, result_count: 1, organization: organization) }
          let(:search_query) { query.origin }
          let(:search_by) { "origin" }

          it_behaves_like "finding the right Query"
        end

        context "when searching by destination" do
          let!(:query) { FactoryBot.create(:api_query, destination: "Cape Town", company: companies_company, client: users_client, result_count: 1, organization: organization) }
          let(:search_query) { query.destination }
          let(:search_by) { "destination" }

          it_behaves_like "finding the right Query"
        end

        context "when searching by imo_class" do
          let!(:commodity_info) { FactoryBot.create(:journey_commodity_info, :imo_class, cargo_unit: query.cargo_units.first) }
          let(:search_query) { commodity_info.description[0..5] }
          let(:search_by) { "imo_class" }

          it_behaves_like "finding the right Query"
        end

        context "when searching by hs_code" do
          let!(:commodity_info) { FactoryBot.create(:journey_commodity_info, :hs_code, cargo_unit: query.cargo_units.first) }
          let(:search_query) { commodity_info.description[0..5] }
          let(:search_by) { "hs_code" }

          it_behaves_like "finding the right Query"
        end

        context "when searching by load_type with a valid search_query" do
          let!(:query) { FactoryBot.create(:api_query, company: companies_company, load_type: "fcl", client: users_client, result_count: 1, organization: organization) }
          let(:search_query) { query.load_type }
          let(:search_by) { "load_type" }

          it_behaves_like "finding the right Query"
        end

        context "when searching by load_type with an invalid search_query" do
          let(:search_query) { "aaa" }
          let(:search_by) { "load_type" }

          it "returns 422 Unprocessable Entity" do
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context "when search_by is missing but search_query is valid" do
          let(:search_query) { "John" }
          let(:search_by) { nil }

          it "returns 422 Unprocessable Entity" do
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end
  end
end
