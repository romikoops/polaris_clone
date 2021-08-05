# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::CarriersController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
    end

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:params) { { organization_id: organization.id } }

    describe "GET #index" do
      let!(:carriers) { FactoryBot.create_list(:routing_carrier, 5) }

      it "successfuly returns a list of all Carriers" do
        get :index, params: { organization_id: organization.id }, as: :json
        expect(response_data.pluck("id")).to match_array(carriers.pluck(:id))
      end
    end

    describe "GET #show" do
      let!(:carrier) { FactoryBot.create(:routing_carrier) }

      it "successfuly returns Carrier" do
        get :show, params: { organization_id: organization.id, id: carrier.id }, as: :json
        expect(response_data["attributes"].keys).to match_array(%w[id name code logo])
      end
    end
  end
end
