# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::CargoItemTypesController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
      FactoryBot.create(:users_membership, organization: organization, user: user)
      FactoryBot.create(
        :legacy_tenant_cargo_item_type, organization_id: organization.id, cargo_item_type: cargo_item_type
      )
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:organization_group) { Organizations::Group.create(organization: organization) }
    let(:user) { FactoryBot.create(:users_user) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:cargo_item_type) { FactoryBot.create(:legacy_cargo_item_type) }

    describe "GET #index" do
      it "renders the list of cargo_item_types successfully" do
        get :index, params: {organization_id: organization.id}

        aggregate_failures do
          expect(response).to be_successful
          expect(response_data.length).to eq(1)
        end
      end
    end
  end
end
