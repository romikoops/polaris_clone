# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::GroupsController, type: :controller do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:user) do
    FactoryBot.create(:users_client, organization: organization, email: "user@itsmycargo.com")
  end
  let(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let(:group) do
    FactoryBot.create(:groups_group, organization: organization, name: "Test").tap do |grp|
      FactoryBot.create(:groups_membership, group: grp, member: user)
    end
  end

  before do
    ::Organizations.current_id = organization.id
    append_token_header
  end

  describe "GET #index" do
    let!(:groups) { FactoryBot.create_list(:groups_group, 5, organization: organization) + [default_group] }

    context "without sorting" do
      it "returns http success", :aggregate_failures do
        get :index, params: { organization_id: organization.id }
        expect(response_data["numPages"]).to eq 1
        expect(response_data["groupData"].map { |c| c["id"] }.sort).to eq groups.map(&:id).sort
      end
    end

    context "with member count sorting" do
      before do
        FactoryBot.create_list(:groups_membership, 4, :for_user, group: group)
        FactoryBot.create_list(:groups_membership, 3, :for_user, group: other_group)
        FactoryBot.create_list(:groups_group, 2, organization: organization)
      end

      let(:other_group) { FactoryBot.create(:groups_group, organization: organization) }

      it "returns http success", :aggregate_failures do
        get :index, params: { organization_id: organization.id, member_count_desc: "true" }

        expect(response_data.dig("groupData", 0, "id")).to eq group.id
        expect(response_data.dig("groupData", 1, "id")).to eq other_group.id
      end
    end

    context "when search target is a user" do
      let(:user2) { FactoryBot.create(:users_client, organization: organization) }
      let(:user_group) { FactoryBot.create(:groups_group, organization: organization, name: "Test Group 2") }

      before do
        FactoryBot.create(:groups_membership, member: user2, group: user_group)
      end

      it "returns the users groups" do
        get :index, params: { organization_id: organization.id,
                              target_type: "user",
                              target_id: user2.id }

        expect(response_data.dig("groupData", 0, "id")).to eq(user_group.id)
      end
    end
  end

  describe "POST #create" do
    let(:create_params) do
      { "addedMembers" =>
        { "clients" =>
          [user.as_json],
          "groups" => [],
          "companies" => [] },
        "name" => "Test",
        "organization_id" => organization.id,
        "group" => { "name" => "Test" } }
    end

    it "returns http success", :aggregate_failures do
      post :create, params: create_params
      expect(response_data["name"]).to eq "Test"
      expect(::Groups::Group.find(response_data["id"]).members.map { |c| c["id"] }).to eq [user.id]
    end
  end

  describe "POST #edit_members" do
    let!(:user_a) { FactoryBot.create(:users_client, organization: organization) }
    let!(:user_b) { FactoryBot.create(:users_client, organization: organization) }
    let(:company_a) { FactoryBot.create(:companies_company, organization: organization) }
    let(:company_b) { FactoryBot.create(:companies_company, organization: organization) }

    let(:edit_params) do
      { "addedMembers" =>
        { "clients" =>
          [user_a.as_json],
          "groups" => [],
          "companies" => [company_a.as_json] },
        "name" => "Test",
        "organization_id" => organization.id,
        "id" => group.id }
    end
    let(:expected) { [user_a.id, company_a.id] }

    before do
      FactoryBot.create(:groups_membership, group: group, member: user_b)
      FactoryBot.create(:groups_membership, group: group, member: company_b)
    end

    it "returns http success", :aggregate_failures do
      post :edit_members, params: edit_params
      expect(response_data["name"]).to eq "Test"
      expect(::Groups::Group.find(response_data["id"]).members.map { |c| c["id"] }).to eq(expected)
    end
  end

  describe "POST #update" do
    let(:edit_params) do
      {
        "name" => "Test2",
        "organization_id" => organization.id,
        "id" => group.id
      }
    end

    it "updates the group name" do
      post :update, params: edit_params

      expect(response_data["name"]).to eq "Test2"
    end
  end

  describe "GET #show" do
    let(:params) do
      {
        "organization_id" => organization.id,
        "id" => group.id
      }
    end

    it "returns http success" do
      get :show, params: params
      expect(response_data["name"]).to eq "Test"
    end

    it "returns 404 when the group is not found" do
      get :show, params: { organization_id: organization.id, id: "aabb" }
      expect(response.status).to eq(404)
    end
  end

  describe "DELETE #destroy" do
    let(:params) do
      {
        "organization_id" => organization.id,
        "id" => group.id
      }
    end

    it "returns http success", :aggregate_failures do
      delete :destroy, params: params

      expect(response).to have_http_status(:success)
      expect(Groups::Group.find_by(id: params["id"])).to be_falsy
    end

    context "when group is a member of another" do
      let(:main_group) { FactoryBot.create(:groups_group) }
      let!(:membership) { FactoryBot.create(:groups_membership, group: main_group, member: group) }

      it "destroys memberships" do
        delete :destroy, params: params

        expect(Groups::Membership.exists?(membership.id)).to eq false
      end
    end
  end
end
