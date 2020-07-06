# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::TruckingCountriesController, type: :controller do
    routes { Engine.routes }
    before do
      request.headers["Authorization"] = token_header
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:user) { FactoryBot.create(:organizations_user, organization: organization) }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:location_1) { FactoryBot.create(:zipcode_location, zipcode: "00001", country_code: "SE") }
    let(:location_2) { FactoryBot.create(:zipcode_location, zipcode: "00002", country_code: "SE") }

    describe "GET #index" do
      let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
      let(:origin_hub) { itinerary.origin_hub }
      let(:destination_hub) { itinerary.destination_hub }
      let(:country_codes) { response_json["data"].map { |country| country["attributes"]["name"] }.uniq }

      before do
        FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location)
        FactoryBot.create(:lcl_on_carriage_availability, hub: destination_hub, query_type: :location)
        FactoryBot.create(:trucking_trucking, organization: organization, hub: origin_hub, location: location_1)
        FactoryBot.create(:trucking_trucking, organization: organization, hub: origin_hub, location: location_2)

        FactoryBot.create(:felixstowe_shanghai_itinerary, organization: organization)
      end

      context "with single country trucking" do
        it "renders the list correct list of countries" do
          get :index, params: {organization_id: organization.id, load_type: "cargo_item", location_type: "destination"}, as: :json

          expect(country_codes).to match_array(["Sweden"])
        end
      end

      context "with cross country trucking" do
        let(:country) { FactoryBot.create(:legacy_country, code: "DE", name: "Germany") }

        before do
          FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location, country: country)
        end

        it "renders the list correct list of countries" do
          get :index, params: {organization_id: organization.id, load_type: "cargo_item", location_type: "destination"}, as: :json

          expect(country_codes).to match_array(["Sweden", "Germany"])
        end
      end
    end
  end
end
