# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::MembershipsController, type: :controller do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_user) }
  let(:client) { FactoryBot.create(:users_client, organization: organization) }

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:groups_group, :default, organization: organization)
    FactoryBot.create(:users_membership, organization: organization, user: user)
    append_token_header
  end

  describe "POST #bulk_edit" do
    let(:group_a) { FactoryBot.create(:groups_group, organization: organization, name: "Group A") }
    let(:group_b) { FactoryBot.create(:groups_group, organization: organization, name: "Group B") }
    let!(:client_a) { FactoryBot.create(:users_client, organization: organization) }
    let(:company_a) { FactoryBot.create(:companies_company, organization: organization) }
    let(:company_b) { FactoryBot.create(:companies_company, organization: organization) }
    let!(:membership_a) { FactoryBot.create(:groups_membership, group: group_a, member: client_a) }
    let!(:membership_b) { FactoryBot.create(:groups_membership, group: group_b, member: client_a) }
    let(:edit_params) {
      {
        addedGroups: [group_a.id],
        targetId: client_a.id,
        targetType: "user",
        memberships:
         [{id: membership_a.id,
           member_type: "Users::Client",
           member_id: client.id,
           group_id: group_a.id,
           priority: 2,
           created_at: "2019-05-09T15:38:08.435Z",
           updated_at: "2019-05-09T15:38:08.435Z",
           member_name: "Agent IMC",
           human_type: "client",
           member_email: "agent@itsmycargo.com",
           original_member_id: client_a.id}],
        organization_id: client.organization_id
      }
    }

    it "returns http success" do
      post :bulk_edit, params: edit_params

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["success"]).to eq true
      expect(json.dig("data").length).to eq 1
      expect(json.dig("data", 0, "priority")).to eq 2
    end
  end

  describe "DELETE #destroy" do
    let(:group) { FactoryBot.create(:groups_group, organization: organization, name: "Discount") }
    let(:membership_user) { FactoryBot.create(:users_client, organization: organization) }
    let(:membership) { FactoryBot.create(:groups_membership, group: group, member: membership_user) }

    it "destroys the membership" do
      delete :destroy, params: {id: membership.id, organization_id: organization.id}
      expect(Groups::Membership.find_by(id: membership.id)).to be(nil)
    end

    it "returns an error when membership is not deleted" do
      allow(controller).to receive(:membership).and_return(instance_double("Membership",
        destroy: false,
        group: group,
        errors: ["error"]))

      delete :destroy, params: {id: membership.id, organization_id: organization.id}
      expect(JSON.parse(response.body)["data"]).to eq(["error"])
    end

    it "renders 404 when membership is not found" do
      delete :destroy, params: {id: "wrong_id", organization_id: organization.id}

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET #index" do
    let(:group) { FactoryBot.create(:groups_group, organization: organization, name: "Discount") }
    let(:membership_user) { client }
    let!(:membership) { FactoryBot.create(:groups_membership, group: group, member: membership_user) }

    it "returns the memberships for a specific user" do
      get :index, params: {targetId: client.id, targetType: "user", organization_id: organization.id}
      aggregate_failures do
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["data"].pluck("id")).to match_array([membership.id])
      end
    end
  end
end
