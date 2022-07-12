# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::Admin::GroupsMembershipsController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_user).tap { |users_user| FactoryBot.create(:users_membership, organization: organization, user: users_user) } }
    let(:groups_group) { FactoryBot.create(:groups_group, organization: organization, name: "demo_group") }
    let(:company) { FactoryBot.create(:companies_company, organization: organization) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }

    shared_examples_for "unauthorized for non users user" do
      it "returns unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "GET #index" do
      context "with company memberships" do
        let(:default_group) { FactoryBot.create(:groups_group, organization: organization, name: "default_group") }
        let(:params) { { organization_id: organization.id, company_id: company.id } }

        before do
          Api::GroupsMembership.create(group: groups_group, member: company)
          Api::GroupsMembership.create(group: default_group, member: company)
        end

        it "returns all the groups memberships for the organisation and ids matching the groups memberships ids" do
          get :index, params: params
          expect(response_data.pluck("id")).to match_array(Api::GroupsMembership.where(member: company).ids)
        end

        it "with pagination params, asserts that a total of one group were returned" do
          get :index, params: { perPage: 1 }.merge(params)
          expect(response_data.length).to eq(1)
        end

        context "when current user is not users user" do
          let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }

          before { get :index, params: params }

          it_behaves_like "unauthorized for non users user"
        end
      end
    end

    describe "POST #create" do
      let(:create_params) { { organization_id: organization.id, company_id: company.id, groupMembership: { groupId: groups_group.id } } }

      context "with valid params" do
        it "returns 201 `created` after company membership was created" do
          post :create, params: create_params
          expect(response).to have_http_status(:created)
        end
      end

      context "when groupId is missing in params" do
        let(:create_params) { { organization_id: organization.id, company_id: company.id, groupMembership: { groupId: "" } } }

        it "fails with 422 unprocessable entity when group_id is missing" do
          post :create, params: create_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns a valid error_code `missing_group_id`" do
          post :create, params: create_params
          expect(response_json["error"]).to eq("missing_group_id")
        end
      end

      context "when group membership already exists" do
        before { Api::GroupsMembership.create(group: groups_group, member: company) }

        it "returns 201 `created`" do
          post :create, params: create_params
          expect(response).to have_http_status(:created)
        end
      end

      context "when current user is not users user" do
        let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }

        before { post :create, params: create_params }

        it_behaves_like "unauthorized for non users user"
      end
    end

    describe "DELETE #destroy" do
      let(:group_membership) { Api::GroupsMembership.create(group: groups_group, member: company) }
      let(:params) { { organization_id: organization.id, company_id: company.id, id: group_membership.id } }

      context "when company has a membership with the group" do
        it "returns 200 OK" do
          delete :destroy, params: params
          expect(response).to have_http_status(:success)
        end
      end

      context "when company is not found" do
        let(:params) { { organization_id: organization.id, company_id: "random_id", id: group_membership.id } }

        it "returns 400 `not_found`" do
          delete :destroy, params: params
          expect(response).to have_http_status(:not_found)
        end

        it "returns error code `company_not_found`" do
          delete :destroy, params: params
          expect(response_json["error"]).to eq("company_not_found")
        end
      end

      context "when company does not have membership with the group" do
        let(:params) { { organization_id: organization.id, company_id: company.id, id: "random_id" } }

        it "returns 422 `Unprocessable Entity`" do
          delete :destroy, params: params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error code `no_membership_found`" do
          delete :destroy, params: params
          expect(response_json["error"]).to eq("no_membership_found")
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
