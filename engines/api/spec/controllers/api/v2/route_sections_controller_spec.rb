# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::RouteSectionsController, type: :controller do
    routes { Engine.routes }

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:result) { FactoryBot.create(:journey_result, sections: 0) }
    let!(:route_section) { FactoryBot.create(:journey_route_section, result: result, carrier: routing_carrier.name) }
    let(:routing_carrier) { FactoryBot.create(:routing_carrier) }
    let(:params) { { result_id: route_section.result_id, organization_id: organization.id } }

    before do
      request.headers["Authorization"] = token_header
    end

    describe "GET #index" do
      it "successfully returns the Result ids for the given ResultSet" do
        get :index, params: params, as: :json
        expect(response_data.pluck("id")).to match_array([route_section.id])
      end
    end
  end
end
