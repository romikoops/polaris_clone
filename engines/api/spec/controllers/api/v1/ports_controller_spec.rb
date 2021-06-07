# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::PortsController, type: :controller do
    routes { Engine.routes }

    let(:organization) { FactoryBot.create(:organizations_organization) }

    describe "GET #ports" do
      let(:itinerary_1) { FactoryBot.create(:hamburg_shanghai_itinerary, organization: organization) }
      let(:itinerary_2) { FactoryBot.create(:shanghai_hamburg_itinerary, organization: organization) }
      let(:first_hub) { itinerary_1.stops.first.hub }
      let(:last_hub) { itinerary_1.stops.last.hub }

      let(:second_organization) { FactoryBot.create(:organizations_organization) }
      let(:itinerary_second_organization) do
        FactoryBot.create(:shanghai_felixstowe_itinerary, organization: second_organization)
      end

      it "returns a list of origin locations belonging to the organization" do
        query = first_hub[:name]
        get :index, params: { organization_id: organization.id, location_type: "origin", query: query }
        data = JSON.parse(response.body)["data"]
        aggregate_failures do
          expect(response).to be_successful
          expect(data.first["attributes"]["name"]).to eq(query)
          expect(data.length).to eq(1)
        end
      end

      it "returns filter related locations to origin" do
        query = last_hub[:name]
        get :index, as: :json, params: {
          organization_id: organization.id, location_type: "origin", location_id: first_hub[:id], query: query
        }
        data = JSON.parse(response.body)["data"]

        aggregate_failures do
          expect(response).to be_successful
          expect(data.first["attributes"]["name"]).to eq(query)
          expect(data.length).to eq(1)
        end
      end

      it "returns filter related locations to destination" do
        query = first_hub[:name]
        get :index, as: :json, params: {
          organization_id: organization.id, location_type: "destination", location_id: last_hub[:id], query: query
        }
        data = JSON.parse(response.body)["data"]

        aggregate_failures do
          expect(response).to be_successful
          expect(data.first["attributes"]["name"]).to eq(query)
          expect(data.length).to eq(1)
        end
      end

      it "filters locations by organization" do
        get :index, as: :json, params: {
          organization_id: second_organization.id, location_type: "origin", query: first_hub[:name]
        }
        data = JSON.parse(response.body)["data"]
        aggregate_failures do
          expect(response).to be_successful
          expect(data).to be_empty
        end
      end

      it "returns empty if there are no locations for the organization" do
        target = FactoryBot.create(:organizations_organization)

        get :index, as: :json, params: { organization_id: target.id, location_type: "origin", query: first_hub[:name] }

        data = JSON.parse(response.body)["data"]
        expect(data.length).to eq(0)
      end

      it "returns :not_found if organization does not exist" do
        get :index, as: :json, params: { organization_id: "invalid_id", location_type: "origin", query: "aaa" }

        expect(response).to have_http_status(:not_found)
      end

      it "returns :bad_request if some of the params (:organization_id and :location_type) are missing" do
        params = { organization_id: organization.id, location_type: "origin", query: "aaa" }

        get :index, as: :json, params: params.except(:location_type)
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
