# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::QueriesController, type: :controller do
    routes { Engine.routes }
    ActiveJob::Base.queue_adapter = :test

    before do
      request.headers["Authorization"] = token_header
      {USD: 1.26, SEK: 8.26}.each do |currency, rate|
        FactoryBot.create(:treasury_exchange_rate, from: currency, to: "EUR", rate: rate)
      end
      FactoryBot.create(:companies_membership, member: user)
    end

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:source) { FactoryBot.create(:application, name: "siren") }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public", application: source) }
    let(:token_header) { "Bearer #{access_token.token}" }

    describe "POST #create" do
      include_context "complete_route_with_trucking"
      let(:cargo_classes) { ["fcl_20"] }
      let(:token_header) { "Bearer #{access_token.token}" }
      let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
      let(:items) { [] }
      let(:load_type) { "container" }
      let(:aggregated) { false }
      let(:origin) {
        FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode)
      }
      let(:destination) {
        FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode)
      }
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
      let(:carta_double) { double("Carta::Api") }

      before do
        allow(Carta::Api).to receive(:new).and_return(carta_double)
        allow(carta_double).to receive(:lookup).with(id: origin.id).and_return(origin)
        allow(carta_double).to receive(:lookup).with(id: destination.id).and_return(destination)
        allow(carta_double).to receive(:suggest).with(query: origin_hub.nexus.locode).and_return(origin_hub.nexus)
        allow(carta_double).to receive(:suggest).with(query: destination_hub.nexus.locode).and_return(
          destination_hub.nexus
        )
      end

      context "when lcl" do
        let(:items) do
          [
            {
              stackable: true,
              valid: true,
              dangerous: false,
              cargoItemTypeId: pallet.id,
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
          expect(response_data.dig("id")).to be_present
        end
      end

      context "when fcl_20" do
        let(:items) do
          [
            {
              valid: true,
              dangerous: false,
              equipmentId: "ee9b339d-6aee-466a-b8d4-b1c08a4731d4",
              quantity: 1,
              weight: 1200,
              commodityCodes: []
            }
          ]
        end
        let(:load_type) { "container" }

        it "successfuly triggers the job and returns the query" do
          post :create, params: params, as: :json
          expect(response_data.dig("id")).to be_present
        end
      end

      context "when LOCODE doesnt match Legacy::Nexus" do
        let(:destination) {
          FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: "ZACPT")
        }

        it "successfuly triggers the job and returns the query" do
          post :create, params: params, as: :json
          expect(response_data.dig("id")).to be_present
        end
      end
    end

    describe "GET #show" do
      include_context "journey_pdf_setup"

      let(:params) { {id: query.id, organization_id: organization.id } }
      context "when lcl" do

        it "successfuly returns the query object", :aggregate_failures do
          get :show, params: params, as: :json
          expect(response_data.dig("id")).to be_present
        end
      end

    end

    describe "GET #result_set" do
      include_context "journey_pdf_setup"
      let(:params)  { {query_id: query.id, organization_id: organization.id } }

      it "successfuly returns the latest ResultSet", :aggregate_failures do
        get :result_set, params: params, as: :json
        expect(response_data.dig("id")).to be_present
      end
    end
  end
end
