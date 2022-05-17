# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ActiveLocodesController, type: :controller do
    routes { Engine.routes }

    before do
      FactoryBot.create(:pricings_pricing, itinerary: gothenburg_shanghai_itinerary, organization: organization)
      request.headers["Authorization"] = token_header
    end

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:params) { { organization_id: organization.id } }
    let(:gothenburg_shanghai_itinerary) { FactoryBot.create(:legacy_itinerary, :gothenburg_shanghai, organization: organization) }

    describe "GET #show" do
      expected_lookup = { "SEGOT" => { "export" => true }, "CNSHA" => { "import" => true } }

      it "successfully returns the lookup of active locodes" do
        get :show, params: params, as: :json
        expect(response_data).to match(expected_lookup)
      end
    end
  end
end
