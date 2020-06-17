# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::TruckingCountriesController, type: :controller do
    routes { Engine.routes }
    before do
      request.headers["Authorization"] = token_header
    end

    let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
    let!(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }
    let!(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }

    describe "GET #index" do
      let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: legacy_tenant) }
      let(:origin_hub) { itinerary.hubs.find_by(name: "Gothenburg Port") }
      let(:destination_hub) { itinerary.hubs.find_by(name: "Shanghai Port") }

      before do
        FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location)
        FactoryBot.create(:lcl_on_carriage_availability, hub: destination_hub, query_type: :location)

        FactoryBot.create(:felixstowe_shanghai_itinerary, tenant: legacy_tenant)
      end

      it "renders the list correct list of countries" do
        get :index, params: {id: tenant.id, load_type: "cargo_item", location_type: "origin"}, as: :json

        country_codes = response_json["data"].map { |country| country["attributes"]["name"] }
        expect(country_codes).to match_array(["Sweden"])
      end
    end
  end
end
