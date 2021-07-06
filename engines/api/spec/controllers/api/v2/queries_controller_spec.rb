# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::QueriesController, type: :controller do
    routes { Engine.routes }
    ActiveJob::Base.queue_adapter = :test

    before do
      request.headers["Authorization"] = token_header
      FactoryBot.create(:companies_membership, member: user)
    end

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public", application: FactoryBot.create(:application, name: "siren")) }
    let(:token_header) { "Bearer #{access_token.token}" }

    describe "POST #create" do
      include_context "complete_route_with_trucking"
      let(:cargo_classes) { ["fcl_20"] }
      let(:token_header) { "Bearer #{access_token.token}" }
      let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
      let(:items) { [] }
      let(:load_type) { "container" }
      let(:aggregated) { false }
      let(:origin) do
        FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode)
      end
      let(:destination) do
        FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode)
      end
      let(:params) do
        {
          aggregated: aggregated,
          items: items,
          loadType: load_type,
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
      end

      context "when lcl" do
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
              commodityCodes: []
            }
          ]
        end
        let(:cargo_classes) { ["lcl"] }
        let(:load_type) { "cargo_item" }

        it "successfuly triggers the job and returns the query", :aggregate_failures do
          post :create, params: params, as: :json

          expect(response_data["id"]).to be_present
        end
      end

      context "when fcl_20" do
        let(:items) do
          [
            {
              cargoClass: "fcl_20",
              quantity: 1,
              weight: 1200,
              commodityCodes: []
            }
          ]
        end
        let(:load_type) { "container" }

        it "successfuly triggers the job and returns the query" do
          post :create, params: params, as: :json
          expect(response_data["id"]).to be_present
        end
      end

      context "when LOCODE doesnt match Legacy::Nexus" do
        let(:destination) do
          FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: "ZACPT")
        end

        it "successfuly triggers the job and returns the query" do
          post :create, params: params, as: :json
          expect(response_data["id"]).to be_present
        end
      end
    end

    describe "GET #show" do
      include_context "journey_pdf_setup"

      let(:params) { { id: query.id, organization_id: organization.id } }

      context "when lcl" do
        it "successfuly returns the query object", :aggregate_failures do
          get :show, params: params, as: :json
          expect(response_data["id"]).to be_present
        end
      end
    end

    describe "GET #result_set" do
      include_context "journey_pdf_setup"
      let(:params) { { query_id: query.id, organization_id: organization.id } }

      it "successfuly returns the latest ResultSet", :aggregate_failures do
        get :result_set, params: params, as: :json
        expect(response_data["id"]).to be_present
      end
    end

    describe "GET #index" do
      let!(:query_a) do
        FactoryBot.create(:journey_query,
          origin: "aaaaa",
          destination: "aaaaa",
          organization: organization,
          cargo_ready_date: 3.days.from_now,
          created_at: 2.hours.ago,
          client: user,
          result_sets: [FactoryBot.build(:journey_result_set, result_count: 1)])
      end
      let!(:query_b) do
        FactoryBot.create(:journey_query,
          origin: "bbbbb",
          destination: "bbbbb",
          organization: organization,
          cargo_ready_date: 2.days.from_now,
          created_at: 5.hours.ago,
          client: user,
          billable: false,
          result_sets: [FactoryBot.build(:journey_result_set, result_count: 1)])
      end

      let(:params) { { organization_id: organization.id } }

      context "when no sorting applied" do
        it "returns the queries", :aggregate_failures do
          get :index, params: params, as: :json
          expect(response_data.pluck("id")).to eq([query_a.id, query_b.id])
        end
      end

      context "when sorting by created_at" do
        it "returns the Queries sorted by created_at desc", :aggregate_failures do
          get :index, params: params.merge(sort_by: "created_at", direction: "desc"), as: :json
          expect(response_data.pluck("id")).to eq([query_a.id, query_b.id])
        end

        it "returns the Queries sorted by created_at asc", :aggregate_failures do
          get :index, params: params.merge(sort_by: "created_at", direction: "asc"), as: :json
          expect(response_data.pluck("id")).to eq([query_b.id, query_a.id])
        end
      end

      context "when sorting by origin" do
        it "returns the Queries sorted by origin desc", :aggregate_failures do
          get :index, params: params.merge(sort_by: "origin", direction: "desc"), as: :json
          expect(response_data.pluck("id")).to eq([query_b.id, query_a.id])
        end

        it "returns the Queries sorted by origin asc", :aggregate_failures do
          get :index, params: params.merge(sort_by: "origin", direction: "asc"), as: :json
          expect(response_data.pluck("id")).to eq([query_a.id, query_b.id])
        end
      end

      context "when sorting by destination" do
        it "returns the Queries sorted by destination desc", :aggregate_failures do
          get :index, params: params.merge(sort_by: "destination", direction: "desc"), as: :json
          expect(response_data.pluck("id")).to eq([query_b.id, query_a.id])
        end

        it "returns the Queries sorted by destination asc", :aggregate_failures do
          get :index, params: params.merge(sort_by: "destination", direction: "asc"), as: :json
          expect(response_data.pluck("id")).to eq([query_a.id, query_b.id])
        end
      end

      context "when sorting by cargo_ready_date" do
        it "returns the Queries sorted by cargo_ready_date desc", :aggregate_failures do
          get :index, params: params.merge(sort_by: "cargo_ready_date", direction: "desc"), as: :json
          expect(response_data.pluck("id")).to eq([query_a.id, query_b.id])
        end

        it "returns the Queries sorted by cargo_ready_date asc", :aggregate_failures do
          get :index, params: params.merge(sort_by: "cargo_ready_date", direction: "asc"), as: :json
          expect(response_data.pluck("id")).to eq([query_b.id, query_a.id])
        end
      end

      context "when paginating" do
        it "returns the Queries sorted by cargo_ready_date desc", :aggregate_failures do
          get :index, params: params.merge(page: 1, per_page: 1), as: :json
          expect(response_data.pluck("id")).to eq([query_a.id])
        end

        it "returns the Queries sorted by cargo_ready_date asc", :aggregate_failures do
          get :index, params: params.merge(page: 2, per_page: 1), as: :json
          expect(response_data.pluck("id")).to eq([query_b.id])
        end
      end
    end
  end
end
