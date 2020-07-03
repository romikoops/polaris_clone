# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::GroupsController, type: :controller do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:user) { create(:organizations_user, :with_profile, organization: organization, email: 'user@itsmycargo.com') }
  let(:group) do
    create(:groups_group, organization: organization, name: "Test").tap do |grp|
      FactoryBot.create(:groups_membership, group: grp, member: user)
    end
  end

  before do
    ::Organizations.current_id = organization.id
    append_token_header
  end

  describe "GET #index" do
    let!(:groups) { create_list(:groups_group, 5, organization: organization) }

    context "without sorting" do
      it "returns http success" do
        get :index, params: {organization_id: organization.id}
        aggregate_failures do
          expect(response).to have_http_status(:success)
          json = JSON.parse(response.body)

          expect(json.dig("data", "numPages")).to eq 1
          expect(json.dig("data", "groupData").map { |c| c["id"] }.sort).to eq groups.map(&:id).sort
        end
      end
    end

    context "with member count sorting" do
      before do
        FactoryBot.create_list(:groups_membership, 4, :user, group: group)
        FactoryBot.create_list(:groups_membership, 3, :user, group: other_group)
        FactoryBot.create_list(:groups_group, 2, organization: organization)
      end

      let(:other_group) { FactoryBot.create(:groups_group, organization: organization) }

      it "returns http success" do
        get :index, params: {organization_id: organization.id, member_count_desc: "true"}
        aggregate_failures do
          expect(response).to have_http_status(:success)
          json = JSON.parse(response.body)
          expect(json.dig("data", "groupData", 0, "id")).to eq group.id
          expect(json.dig("data", "groupData", 1, "id")).to eq other_group.id
        end
      end
    end

    context "when search target is a user" do
      let(:user_2) { FactoryBot.create(:organizations_user, :with_profile, organization: organization) }
      let(:user_group) { FactoryBot.create(:groups_group, organization: organization, name: "Test Group 2") }

      before do
        FactoryBot.create(:groups_membership, member: user_2, group: user_group)
      end

      it "returns the users groups" do
        get :index, params: {organization_id: organization.id,
                             target_type: 'user',
                             target_id: user_2.id}
        aggregate_failures do
          json_response = JSON.parse(response.body)
          expect(response).to have_http_status(:success)
          expect(json_response.dig('data', 'groupData').first.dig('id')).to eq(user_group.id)
        end
      end
    end
  end

  describe "POST #create" do
    let(:create_params) do
      {"addedMembers" =>
        {"clients" =>
          [user.as_json],
         "groups" => [],
         "companies" => []},
       "name" => "Test",
       "organization_id" => organization.id,
       "group" => {"name" => "Test"}}
    end

    it "returns http success" do
      post :create, params: create_params
      aggregate_failures do
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["success"]).to eq true
        expect(json.dig("data", "name")).to eq "Test"
        expect(::Groups::Group.find(json.dig("data", "id")).members.map { |c| c["id"] }).to eq [user.id]
      end
    end
  end

  describe "POST #edit_members" do
    let!(:user_a) { create(:organizations_user, :with_profile, organization: organization) }
    let!(:user_b) { create(:organizations_user, :with_profile, organization: organization) }
    let(:company_a) { create(:companies_company, organization: organization) }
    let(:company_b) { create(:companies_company, organization: organization) }

    let(:profile) { FactoryBot.build(:profiles_profile) }
    let(:edit_params) do
      {"addedMembers" =>
        {"clients" =>
          [user_a.as_json],
         "groups" => [],
         "companies" => [company_a.as_json]},
       "name" => "Test",
       "organization_id" => organization.id,
       "id" => group.id}
    end
    let(:expected) { [user_a.id, company_a.id] }

    before do
      create(:groups_membership, group: group, member: user_b)
      create(:groups_membership, group: group, member: company_b)
    end

    it "returns http success" do
      post :edit_members, params: edit_params
      aggregate_failures do
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json.dig("data", "name")).to eq "Test"
        expect(::Groups::Group.find(json.dig("data", "id")).members.map { |c| c["id"] }).to eq(expected)
      end
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
      aggregate_failures do
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json.dig("data", "name")).to eq "Test2"
      end
    end
  end

  describe "GET #show" do
    let(:edit_params) do
      {
        "organization_id" => organization.id,
        "id" => group.id
      }
    end

    it "returns http success" do
      get :show, params: edit_params
      aggregate_failures do
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["success"]).to eq true
        expect(json.dig("data", "name")).to eq "Test"
      end
    end
  end

  describe "DELETE #destroy" do
    let(:edit_params) do
      {
        "organization_id" => organization.id,
        "id" => group.id
      }
    end

    it "returns http success" do
      delete :destroy, params: edit_params
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(Groups::Group.find_by(edit_params[:id])).to be_falsy
      end
    end
  end
end
