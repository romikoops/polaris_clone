# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::WidgetsController, type: :controller do
    routes { Engine.routes }
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:organizations_user, email: "test@example.com", organization: organization) }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:response_data) { JSON.parse(response.body).dig("data") }

    before do
      request.headers["Authorization"] = token_header
    end

    describe "GET #index" do
      before do
        FactoryBot.create_list(:cms_data_widget, 5, organization: organization, data: "Test Widget Data")
      end

      it "returns the widgets for the organization specified" do
        get :index, params: {organization_id: organization.id}
        aggregate_failures do
          expect(response_data.count).to eq(5)
          expect(response_data.first.dig("attributes", "data")).to eq("Test Widget Data")
        end
      end
    end
  end
end
