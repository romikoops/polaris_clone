# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizationsController do
  let!(:user) { create(:organizations_user, email: "user@itsmycargo.com") }
  let(:organization) { user.organization }
  let(:domain) { create(:organizations_domain, organization: organization) }

  before do
    request.env["HTTP_REFERER"] = "http://itsmycargo.example"
    FactoryBot.create(:organizations_theme, organization: organization)
  end

  describe "GET #index" do
    it "returns http success" do
      get :index

      expect(response).to have_http_status(:success)
    end

    it "returns an empty list on production mode" do
      allow(Rails.env).to receive("production?").and_return(true)

      get :index

      json = JSON.parse(response.body)
      expect(json.dig("data")).to be_empty
    end

    it "returns tenants without production mode" do
      allow(Rails.env).to receive("production?").and_return(false)

      get :index

      json = JSON.parse(response.body)
      expect(json.dig("data", 0, "value", "id")).to eq(organization.id)
    end
  end

  describe "GET #get_tenant" do
    it "returns http success" do
      get :get_tenant, params: {organization_id: organization.id, name: organization.slug}

      expect(response).to have_http_status(:success)
    end

    it "returns the tenant" do
      get :get_tenant, params: {organization_id: organization.id, name: organization.slug}

      json = JSON.parse(response.body)
      expect(json.dig("id")).to eq organization.id
    end

    it "returns 400 if the tenant is not found" do
      get :get_tenant, params: {organization_id: organization.id, name: "not found tenant"}

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "GET #fetch_scope" do
    it "returns http success" do
      get :fetch_scope, params: {organization_id: organization.id}

      expect(response).to have_http_status(:success)
    end

    it "returns the tenant scope" do
      get :fetch_scope, params: {organization_id: organization.id}

      json = JSON.parse(response.body)
      expect(json.dig("data", "fee_detail")).to eq("key_and_name")
    end

    it "returns the tenant scope with current_user" do
      get :fetch_scope, params: {organization_id: organization.id}

      json = JSON.parse(response.body)
      expect(json.dig("data", "fee_detail")).to eq("key_and_name")
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: {id: organization.id}
      expect(response).to have_http_status(:success)
    end

    it "returns the tenant without user" do
      get :show, params: {id: organization.id}

      json = JSON.parse(response.body)
      expect(json.dig("data", "tenant", "id")).to eq(organization.id)
    end

    it "returns the tenant with user" do
      get :show, params: {id: organization.id}

      json = JSON.parse(response.body)
      expect(json.dig("data", "tenant", "id")).to eq(organization.id)
    end
  end

  describe "GET #current" do
    before do
      request.headers[:HTTP_REFERER] = "http://#{domain.domain}"
      get :current
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns the current tenant" do
      json = JSON.parse(response.body)
      expect(json.dig("data", "organization_id")).to eq(organization.id)
    end
  end
end
