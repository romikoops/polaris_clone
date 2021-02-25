# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ThemesController, type: :controller do
    routes { Engine.routes }

    let(:theme) { FactoryBot.build(:organizations_theme) }
    let!(:organization) { FactoryBot.create(:organizations_organization, theme: theme) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:params) { {organization_id: organization.id} }

    describe "GET #show" do

      it "successfuly returns the Errors for the given ResultSet" do
        get :show, params: params, as: :json
        expect(response_data.dig("id")).to eq(theme.id)
        expect(response_data.dig("attributes").keys).to eq(
          ["id", "organizationId", "emails", "websites", "addresses", "emailLinks",
            "name", "phones", "background", "smallLogo", "largeLogo", "whiteLogo", "wideLogo"])
      end
    end
  end
end
