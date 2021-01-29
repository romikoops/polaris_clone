# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ErrorsController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
    end

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:result_set) { FactoryBot.create(:journey_result_set) }
    let(:params) { {result_set_id: result_set.id, organization_id: organization.id} }

    describe "GET #index" do
      let!(:error) { FactoryBot.create(:journey_error, result_set: result_set) }

      it "successfuly returns the Errors for the given ResultSet" do
        get :index, params: params, as: :json
        expect(response_data.dig(0, "attributes", "id")).to eq(error.id)
      end
    end
  end
end
