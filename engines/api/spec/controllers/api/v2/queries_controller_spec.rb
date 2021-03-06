# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::QueriesController, type: :controller do
    routes { Engine.routes }
    ActiveJob::Base.queue_adapter = :test

    before do
      request.headers["Authorization"] = token_header
      FactoryBot.create(:companies_membership, client: client, company: company)
    end

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:client) { FactoryBot.create(:api_client, organization_id: organization.id) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: client.id, scopes: "public", application: FactoryBot.create(:application, name: "siren")) }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:company) { FactoryBot.create(:companies_company, organization: organization) }

    describe "POST #create" do
      include_context "complete_route_with_trucking"
      let(:parent_id) { nil }
      let(:origin) do
        FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode)
      end
      let(:destination) do
        FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode)
      end
      let(:items) do
        [
          {
            cargoClass: "lcl",
            stackable: true,
            colliType: "pallet",
            quantity: 1,
            length: 120,
            width: 100,
            height: 120,
            weight: 1200,
            commodities: []
          }
        ]
      end
      let(:cargo_classes) { ["lcl"] }
      let(:load_type) { "cargo_item" }
      let(:params) do
        {
          items: items,
          loadType: load_type,
          cargoReadyDate: Time.zone.tomorrow,
          parentId: parent_id,
          originId: origin.id,
          destinationId: destination.id,
          organization_id: organization.id
        }
      end

      before do
        { USD: 1.26, SEK: 8.26 }.each do |currency, rate|
          FactoryBot.create(:treasury_exchange_rate, from: currency, to: "EUR", rate: rate)
        end
        allow(Carta::Client).to receive(:lookup).with(id: origin.id).and_return(origin)
        allow(Carta::Client).to receive(:lookup).with(id: destination.id).and_return(destination)
        allow(Carta::Client).to receive(:suggest).with(query: origin_hub.nexus.locode).and_return(origin_hub.nexus)
        allow(Carta::Client).to receive(:suggest).with(query: destination_hub.nexus.locode).and_return(
          destination_hub.nexus
        )
        FactoryBot.create(:legacy_cargo_item_type)
        access_token
      end

      context "when lcl" do
        before { post :create, params: params, as: :json }

        it "successfuly triggers the job and returns the query", :aggregate_failures do
          expect(response_data["id"]).to be_present
          expect(DateTime.parse(response_data.dig("attributes", "cargoReadyDate"))).to eq(Time.zone.tomorrow)
        end
      end

      context "when there is no auth provided" do
        let(:token_header) { "Bearer " }

        before { post :create, params: params, as: :json }

        it "successfuly triggers the job and returns the query", :aggregate_failures do
          expect(response_data["id"]).to be_present
          expect(response_data.dig("attributes", "client", "id")).to be_nil
        end
      end

      context "when fcl_20" do
        let(:items) do
          [
            {
              cargoClass: "fcl_20",
              quantity: 1,
              weight: 1200,
              commodities: []
            }
          ]
        end
        let(:load_type) { "container" }

        before { post :create, params: params, as: :json }

        it "successfuly triggers the job and returns the query" do
          expect(response_data["id"]).to be_present
        end
      end

      context "when LOCODE doesnt match Legacy::Nexus" do
        let(:destination) do
          FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: "ZACPT")
        end

        before { post :create, params: params, as: :json }

        it "successfuly triggers the job and returns the query" do
          expect(response_data["id"]).to be_present
        end
      end

      context "when parent_id is part of params" do
        let(:parent_id) do
          FactoryBot.create(:journey_query).id
        end

        before { post :create, params: params, as: :json }

        it "successfuly triggers the job and returns the query" do
          expect(response_data["attributes"]["parentId"]).to be_present
        end
      end

      context "when items are empty" do
        let(:items) { [] }

        before { post :create, params: params, as: :json }

        it "returns invalid params", :aggregate_failures do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({ "items" => ["must be present"] })
        end
      end

      context "when item is missing cargo class" do
        let(:items) do
          [
            {
              cargoClass: nil,
              quantity: 1,
              weight: 1200,
              commodities: []
            }
          ]
        end

        before { post :create, params: params, as: :json }

        it "returns invalid params", :aggregate_failures do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({ "items" => { "0" => { "cargoClass" => ["must be filled"] } } })
        end
      end

      context "when an error is raised" do
        before do
          query_generator_double = instance_double(OfferCalculator::Service::QueryGenerator)
          allow(OfferCalculator::Service::QueryGenerator).to receive(:new).and_return(query_generator_double)
          allow(query_generator_double).to receive(:query).and_raise(OfferCalculator::Errors::InvalidQuery)
          post :create, params: params, as: :json
        end

        it "returns the error message and code", :aggregate_failures do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({ "error" => "OfferCalculator::Errors::InvalidQuery", "code" => 1012 })
        end
      end
    end

    describe "GET #show" do
      include_context "journey_pdf_setup"

      let(:params) { { id: query.id, organization_id: organization.id } }

      context "when lcl" do
        let(:expected_data) do
          {
            "id" => query.id,
            "billable" => true,
            "loadType" => "cargo_item",
            "originName" => query.origin,
            "destinationName" => query.destination,
            "reference" => line_item_set.reference,
            "modesOfTransport" => ["ocean"],
            "client" =>
         { "data" =>
           { "id" => query.client_id,
             "type" => "client",
             "attributes" =>
             { "email" => query.client.email,
               "organizationId" => organization.id,
               "firstName" => query.client.profile.first_name,
               "lastName" => query.client.profile.last_name,
               "phone" => query.client.profile.phone,
               "companyName" => company.name,
               "lastActivityAt" => query.client.last_activity_at } },
           "meta" => {},
           "links" => {} },
            "offerId" => nil,
            "issueDate" => query.created_at,
            "currency" => query.currency,
            "originId" => query.origin_geo_id,
            "destinationId" => query.destination_geo_id,
            "parentId" => nil,
            "companyId" => query.company_id,
            "cargoReadyDate" => query.cargo_ready_date
          }
        end

        it "successfuly returns the query object" do
          get :show, params: params, as: :json

          expect(response_data["attributes"]).to eq(expected_data.as_json)
        end
      end
    end

    describe "POST #recalculate" do
      let(:query) { FactoryBot.create(:journey_query, organization: organization, source_id: access_token.application_id, status: "failed") }

      let(:params) { { query_id: query.id, organization_id: organization.id } }

      it "successfuly returns the new query object", :aggregate_failures do
        post :recalculate, params: params, as: :json
        expect(response_data["id"]).not_to eq(query.id)
        expect(response_data.dig("attributes", "parentId")).to eq(query.id)
      end

      context "when the Query is invalid" do
        let(:query) do
          FactoryBot.build(:journey_query, organization: organization, source_id: access_token.application_id, origin_geo_id: nil, status: "failed")
            .tap { |invalid_query| invalid_query.save(validate: false) }
        end

        it "returns the error message and code", :aggregate_failures do
          post :recalculate, params: params, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({ "error" => "OfferCalculator::Errors::InvalidQuery", "code" => 1012 })
        end
      end
    end

    describe "PATCH #update" do
      let(:params) { { id: query.id, organization_id: organization.id } }

      context "when query has no client" do
        let(:query) { FactoryBot.create(:journey_query, organization: organization, client_id: nil, creator: nil) }

        it "successfuly returns the query object", :aggregate_failures do
          patch :update, params: params, as: :json
          expect(response_data["id"]).to be_present
          expect(response_data.dig("attributes", "client", "data", "id")).to eq(client.id)
          expect(response_data.dig("attributes", "companyId")).to eq(company.id)
        end
      end

      context "when query has a client" do
        let(:query) { FactoryBot.create(:journey_query, organization: organization) }

        it "returns unauthorised" do
          patch :update, params: params, as: :json
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when query has no client, but wrong organization" do
        let(:query) { FactoryBot.create(:journey_query) }

        it "returns unauthorised" do
          patch :update, params: params, as: :json
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    describe "GET #result_set" do
      let(:query) { FactoryBot.create(:journey_query, organization: organization, status: "running") }
      let(:params) { { query_id: query.id, organization_id: organization.id } }

      context "when the Query is still running" do
        it "returns the status 'running'", :aggregate_failures do
          get :result_set, params: params, as: :json
          expect(response_data.dig("attributes", "status")).to eq("running")
        end
      end

      context "when the Query has failed" do
        before { FactoryBot.create(:journey_query_calculation, query: query, status: "failed") }

        it "returns the status 'failed'", :aggregate_failures do
          get :result_set, params: params, as: :json
          expect(response_data.dig("attributes", "status")).to eq("failed")
        end
      end

      context "when the Query has completed" do
        before { FactoryBot.create(:journey_query_calculation, query: query, status: "completed") }

        it "returns the status 'completed'", :aggregate_failures do
          get :result_set, params: params, as: :json
          expect(response_data.dig("attributes", "status")).to eq("completed")
        end
      end
    end

    describe "GET #index" do
      let(:params) { { organization_id: organization.id } }

      context "when sorting " do
        let!(:query_a) do
          FactoryBot.create(:journey_query,
            origin: "aaaaa",
            destination: "aaaaa",
            organization: organization,
            cargo_ready_date: 3.days.from_now,
            created_at: 2.hours.ago,
            client: client,
            results: [FactoryBot.build(:journey_result)])
        end
        let!(:query_b) do
          FactoryBot.create(:journey_query,
            origin: "bbbbb",
            destination: "bbbbb",
            organization: organization,
            cargo_ready_date: 2.days.from_now,
            created_at: 5.hours.ago,
            client: client,
            billable: false,
            results: [FactoryBot.build(:journey_result)])
        end

        context "when no sorting applied" do
          it "returns the queries", :aggregate_failures do
            get :index, params: params, as: :json
            expect(response_data.pluck("id")).to eq([query_a.id, query_b.id])
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
        let!(:query) { FactoryBot.create(:api_query, result_count: 1, client: client, organization: organization) }

        before do
          FactoryBot.create_list(:api_query, 2, result_count: 1, organization: organization, client: client)
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

        context "when searching by company_name" do
          let(:search_query) { query.company.name }
          let(:search_by) { "company_name" }

          it_behaves_like "finding the right Query"
        end

        context "when searching by origin" do
          let!(:query) { FactoryBot.create(:api_query, origin: "Cape Town", client: client, result_count: 1, organization: organization) }
          let(:search_query) { query.origin }
          let(:search_by) { "origin" }

          it_behaves_like "finding the right Query"
        end

        context "when searching by destination" do
          let!(:query) { FactoryBot.create(:api_query, destination: "Cape Town", client: client, result_count: 1, organization: organization) }
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
          let!(:query) { FactoryBot.create(:api_query, load_type: "fcl", client: client, result_count: 1, organization: organization) }
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
