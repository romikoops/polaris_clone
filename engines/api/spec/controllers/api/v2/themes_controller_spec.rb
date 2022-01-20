# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ThemesController, type: :controller do
    routes { Engine.routes }

    let(:theme) { FactoryBot.build(:organizations_theme, :with_landing_pages) }
    let!(:organization) { FactoryBot.create(:organizations_organization, theme: theme) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:params) { { organization_id: organization.id } }

    describe "GET #show" do
      before { get :show, params: params, as: :json }

      it "returns a 200 OK response" do
        expect(response).to have_http_status(:ok)
      end

      it "successfully returns the Theme for the Current Organization" do
        expect(response_data["id"]).to eq(theme.id)
      end
    end
  end
end
