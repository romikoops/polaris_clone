# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::Admin::GroupsController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
      FactoryBot.create(:groups_group, organization: organization, name: "demo group")
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_user).tap { |users_user| FactoryBot.create(:users_membership, organization: organization, user: users_user) } }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }

    shared_examples_for "unauthorized for non users user" do
      it "returns unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "GET #index" do
      before { FactoryBot.create(:groups_group, name: "zee", organization: organization) }

      let(:params) { { organization_id: organization.id } }

      it "returns all the companies for the organisation and ids matching the companies ids" do
        get :index, params: params
        expect(response_data.pluck("id")).to match_array(Api::Group.where(organization: organization).ids)
      end

      it "with pagination params, asserts that a total of one group were returned" do
        get :index, params: { organization_id: organization.id, perPage: 1 }
        expect(response_data.length).to eq(1)
      end

      context "with invalid searchBy" do
        let(:params) { { organization_id: organization.id, searchBy: "origin", searchQuery: "Germany" } }

        before { get :index, params: params }

        it "returns unprocessable entity" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when current user is not users user" do
        let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }

        before { get :index, params: params }

        it_behaves_like "unauthorized for non users user"
      end
    end

    describe "POST #create" do
      let(:create_params) { { name: "test-group" } }

      context "with valid params" do
        it "returns 201 `created` after the group was created" do
          post :create, params: { organization_id: organization.id, group: create_params }
          expect(response).to have_http_status(:created)
        end
      end

      context "when name is missing in params" do
        it "fails with 400 bad request when name is missing" do
          post :create, params: { organization_id: organization.id, group: create_params.tap { |params| params.delete(:name) } }
          expect(response).to have_http_status(:bad_request)
        end
      end

      context "when current user is not users user" do
        let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }

        before { post :create, params: { organization_id: organization.id, company: create_params } }

        it_behaves_like "unauthorized for non users user"
      end
    end

    describe "DELETE #destroy" do
      let(:group) { FactoryBot.create(:groups_group, organization: organization) }
      let(:params) { { organization_id: organization.id, id: group.id } }

      context "with valid params" do
        it "returns 200 OK" do
          delete :destroy, params: params
          expect(response).to have_http_status(:success)
        end
      end

      context "when group is not found" do
        let(:params) { { organization_id: organization.id, id: "random_id" } }

        it "returns 404  Not found" do
          delete :destroy, params: params
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when current user is not users user" do
        let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }

        before { delete :destroy, params: params }

        it_behaves_like "unauthorized for non users user"
      end
    end
  end
end
