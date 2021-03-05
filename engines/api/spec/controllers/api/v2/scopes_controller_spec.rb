# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ScopesController, type: :controller do
    routes { Engine.routes }

    let(:scope_content) { { links: {link1: "link1"}} }
    let(:scope) { FactoryBot.build(:organizations_scope, content: scope_content) }
    let!(:organization) { FactoryBot.create(:organizations_organization, scope: scope) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:params) { {organization_id: organization.id} }

    describe "GET #show" do
      context "when request is unauthenticated" do
        let(:expected_content) { Organizations::DEFAULT_SCOPE["links"].merge("link1"=>"link1") }

        it "successfully returns the Scope Object" do
          get :show, params: params, as: :json
          expect(response_data.dig("attributes", "links")).to match(expected_content)
        end
      end

      context "when request is authenticated" do
        before do
          request.headers["Authorization"] = token_header
          FactoryBot.create(:organizations_scope, target: user, content: { links: {link2: "link2"}})
        end

        let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
        let(:token_header) { "Bearer #{access_token.token}" }

        let(:expected_content) { Organizations::DEFAULT_SCOPE["links"].merge("link1"=>"link1", "link2"=>"link2") }

        it "successfuly returns the Scope Object" do
          get :show, params: params, as: :json
          expect(response_data.dig("attributes", "links")).to match(expected_content)
        end
      end
    end
  end
end
