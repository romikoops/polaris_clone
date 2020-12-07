# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::AhoyController, type: :controller do
    routes { Engine.routes }
    let(:organization) { FactoryBot.create(:organizations_organization) }

    describe "GET #settings" do
      it "returns the settings of the organization" do
        get :index, params: {organization_id: organization.id}, as: :json

        aggregate_failures do
          expect(response).to be_successful
          expect(response.body).not_to be_empty

          data = JSON.parse(response.body)
          expect(data).not_to be_nil
        end
      end

      it "returns 404 if organization does not exist" do
        get :index, params: {organization_id: "Invalid Organization UUID"}, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
