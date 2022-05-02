# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ScopesController, type: :controller do
    routes { Engine.routes }

    let(:scope_content) { { closed_shop: true, links: { link1: "link1" }, closed_registration: false } }
    let(:scope) { FactoryBot.build(:organizations_scope, content: scope_content) }
    let!(:organization) { FactoryBot.create(:organizations_organization, scope: scope) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:params) { { organization_id: organization.id } }

    describe "GET #show" do
      let(:default_content) do
        {
          "links" => Organizations::DEFAULT_SCOPE["links"].merge("link1" => "link1"),
          "loginMandatory" => scope_content[:closed_shop],
          "registrationProhibited" => scope_content[:closed_registration],
          "loginSamlText" => Organizations::DEFAULT_SCOPE["saml_text"],
          "authMethods" => ["password"]
        }
      end

      shared_examples_for "it returns the scope attributes" do
        it "successfully returns the Scope Object" do
          get :show, params: params, as: :json
          expect(response_data["attributes"].except("id")).to match(expected_content)
        end
      end

      context "when request is unauthenticated" do
        let(:expected_content) { default_content }

        it_behaves_like "it returns the scope attributes"
      end

      context "when request is authenticated" do
        before do
          request.headers["Authorization"] = token_header
          FactoryBot.create(:organizations_scope, target: user, content: { closed_shop: false, links: { link2: "link2" } })
        end

        let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
        let(:token_header) { "Bearer #{access_token.token}" }
        let(:expected_content) do
          default_content.merge(
            "links" => Organizations::DEFAULT_SCOPE["links"].merge("link1" => "link1", "link2" => "link2"),
            "loginMandatory" => false
          )
        end

        it_behaves_like "it returns the scope attributes"
      end

      context "when shop is SAML enabled" do
        before do
          Organizations.current_id = organization.id
          FactoryBot.create(:organizations_saml_metadatum, organization: organization)
        end

        let(:expected_content) { default_content.merge("authMethods" => %w[password saml]) }

        it_behaves_like "it returns the scope attributes"
      end
    end
  end
end
