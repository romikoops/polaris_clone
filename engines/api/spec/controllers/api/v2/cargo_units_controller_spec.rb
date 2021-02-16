# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::CargoUnitsController, type: :controller do
    routes { Engine.routes }

    before do
      FactoryBot.create(:legacy_tenant_cargo_item_type, organization: organization)
      request.headers["Authorization"] = token_header
    end

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:query) { FactoryBot.build(:journey_query, organization: organization, client: user, cargo_units: []) }
    let(:params) { {query_id: query.id, organization_id: organization.id} }

    describe "GET #index" do
      let!(:cargo_units) {
        FactoryBot.create_list(:journey_cargo_unit, 3, query: query)
      }

      it "successfuly returns the Result ids for the given ResultSet" do
        get :index, params: params, as: :json
        expect(response_data.pluck("id")).to match_array(cargo_units.pluck(:id))
      end
    end

    describe "GET #show" do
      let(:cargo_unit) { FactoryBot.create(:journey_cargo_unit, query: query) }
      let(:params) { {id: cargo_unit.id, query_id: query.id, organization_id: organization.id} }

      it "successfuly returns the Errors for the given ResultSet" do
        get :show, params: params, as: :json
        expect(response_data.dig("id")).to eq(cargo_unit.id)
      end
    end
  end
end
