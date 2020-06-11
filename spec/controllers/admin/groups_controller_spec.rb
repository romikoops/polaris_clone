# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::GroupsController, type: :controller do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { create(:legacy_user, tenant: tenant, email: "user@itsmycargo.com", with_profile: true) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:group) do
    create(:tenants_group, tenant: tenants_tenant, name: "Test").tap do |tapped_group|
      FactoryBot.create(:tenants_membership, group: tapped_group, member: tenants_user)
    end
  end

  before do
    allow(controller).to receive(:user_signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:require_login_and_role_is_admin).and_return(true)
  end

  describe "GET #index" do
    let!(:groups) { create_list(:tenants_group, 5, tenant: tenants_tenant) }

    context "without sorting" do
      it "returns http success" do
        get :index, params: {tenant_id: tenant.id}
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
        FactoryBot.create_list(:tenants_membership, 4, :user, group: group)
        FactoryBot.create_list(:tenants_membership, 3, :user, group: other_group)
        FactoryBot.create_list(:tenants_group, 2, tenant: tenants_tenant)
      end

      let(:other_group) { FactoryBot.create(:tenants_group, tenant: tenants_tenant) }

      it "returns http success" do
        get :index, params: {tenant_id: tenant.id, member_count_desc: "true"}
        aggregate_failures do
          expect(response).to have_http_status(:success)
          json = JSON.parse(response.body)
          expect(json.dig("data", "groupData", 0, "id")).to eq group.id
          expect(json.dig("data", "groupData", 1, "id")).to eq other_group.id
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
       "tenant_id" => tenant.id,
       "group" => {"name" => "Test"}}
    end

    it "returns http success" do
      post :create, params: create_params
      aggregate_failures do
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["success"]).to eq true
        expect(json.dig("data", "name")).to eq "Test"
        expect(::Tenants::Group.find(json.dig("data", "id")).members.map { |c| c["id"] }).to eq [user.id]
      end
    end
  end

  describe "POST #edit_members" do
    let!(:user_a) { create(:legacy_user, tenant: tenant, with_profile: true) }
    let!(:user_b) { create(:legacy_user, tenant: tenant, with_profile: true) }
    let(:company_a) { create(:tenants_company, tenant: tenants_tenant) }
    let(:company_b) { create(:tenants_company, tenant: tenants_tenant) }

    let(:profile) { FactoryBot.build(:profiles_profile) }
    let(:edit_params) do
      {"addedMembers" =>
        {"clients" =>
          [user_a.as_json],
         "groups" => [],
         "companies" => [company_a.as_json]},
       "name" => "Test",
       "tenant_id" => tenant.id,
       "id" => group.id}
    end
    let(:expected) { [user_a.id, company_a.id] }

    before do
      create(:tenants_membership, group: group, member: Tenants::User.find_by(legacy_id: user_b.id))
      create(:tenants_membership, group: group, member: company_b)
    end

    it "returns http success" do
      post :edit_members, params: edit_params
      aggregate_failures do
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json.dig("data", "name")).to eq "Test"
        expect(::Tenants::Group.find(json.dig("data", "id")).members.map { |c| c["id"] }).to eq(expected)
      end
    end
  end

  describe "POST #update" do
    let(:edit_params) do
      {
        "name" => "Test2",
        "tenant_id" => tenant.id,
        "id" => group.id
      }
    end

    it "rupdates the group name" do
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
        "tenant_id" => tenant.id,
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
        "tenant_id" => tenant.id,
        "id" => group.id
      }
    end

    it "returns http success" do
      delete :destroy, params: edit_params
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(Tenants::Group.find_by(edit_params[:id])).to be_falsy
      end
    end
  end
end
