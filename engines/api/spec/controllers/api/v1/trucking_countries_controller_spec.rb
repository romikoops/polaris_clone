# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::TruckingCountriesController, type: :controller do
    routes { Engine.routes }
    include_context "complete_route_with_trucking"

    before do
      request.headers["Authorization"] = token_header
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:user) { FactoryBot.create(:organizations_user, organization: organization) }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:country) { FactoryBot.create(:country_se) }
    let(:cargo_classes) { ["lcl"] }
    let(:load_type) { "cargo_item" }

    describe "GET #index" do
      let(:country_codes) { response_json["data"].map { |country| country["attributes"]["name"] }.uniq }

      before do
        FactoryBot.create(:felixstowe_shanghai_itinerary, organization: organization)
      end

      context "with single country trucking" do
        it "renders the list correct list of countries" do
          get :index, params: {organization_id: organization.id, load_type: "cargo_item", location_type: "destination"}, as: :json

          expect(country_codes).to match_array(["Sweden"])
        end
      end

      context "with cross country trucking" do
        let(:other_country) { FactoryBot.create(:legacy_country, code: "DE", name: "Germany") }

        before do
          FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location, country: other_country)
        end

        it "renders the list correct list of countries" do
          get :index, params: {organization_id: organization.id, load_type: "cargo_item", location_type: "destination"}, as: :json

          expect(country_codes).to match_array(["Sweden", "Germany"])
        end
      end
    end
  end
end
