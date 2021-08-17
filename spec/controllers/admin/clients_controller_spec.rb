# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ClientsController do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:resp) { JSON.parse(response.body) }
  let(:user) { FactoryBot.create(:users_user) }

  before do
    FactoryBot.create(:groups_group, :default, organization: organization)
    stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700")
      .to_return(status: 200, body: "", headers: {})
    append_token_header
  end

  describe "GET #index" do
    let(:company) { FactoryBot.create(:companies_company, name: "ItsMyCargo", organization_id: organization.id) }
    let(:users) { FactoryBot.create_list(:users_client, 3, organization: organization) + [client] }
    let!(:client) { FactoryBot.create(:users_client, organization: organization, profile_attributes: { first_name: "Bob", last_name: "Smith" }) }

    before do
      ::Organizations.current_id = organization.id
      users.each do |other_user|
        FactoryBot.create(:companies_membership, company: company, client: other_user)
      end
    end

    it "returns an http status of success" do
      get :index, params: { organization_id: organization.id }
      expect(response).to have_http_status(:success)
    end

    context "with first name search" do
      it "returns the correct matching results with search" do
        get :index, params: { organization_id: organization.id, first_name: client.profile.first_name }

        expect(resp.dig("data", "clientData", 0, "email")).to eq(client.email)
      end
    end

    context "with last name search" do
      it "returns the correct matching results with search" do
        get :index, params: { organization_id: organization.id, last_name: client.profile.last_name }

        expect(resp.dig("data", "clientData", 0, "email")).to eq(client.email)
      end
    end

    context "with last name search and other sort applied" do
      it "returns the correct matching results with search" do
        get :index, params: { organization_id: organization.id, last_name: client.profile.last_name, company_name_desc: true }

        expect(resp.dig("data", "clientData", 0, "email")).to eq(client.email)
      end
    end

    context "when searching via company names" do
      it "returns users matching the given company_name " do
        get :index, params: { organization_id: organization.id, company_name: company.name[0, 3] }

        expect(resp["data"]["clientData"].pluck("email")).to include(users.first.email)
      end
    end

    context "when the user has soft deleted their membership" do
      before { FactoryBot.create(:companies_membership, client: client, deleted_at: 5.minutes.ago) }

      it "returns only one user" do
        get :index, params: { organization_id: organization.id, email: client.email }

        expect(resp["data"]["clientData"].pluck("id")).to match_array([client.id])
      end
    end

    context "when user does not belong to a company" do
      let!(:other_client) { FactoryBot.create(:users_client, organization: organization) }

      it "returns users matching the given company_name " do
        get :index, params: { organization_id: organization.id, email: other_client.email[0, 4] }

        expect(resp["data"]["clientData"].pluck("email")).to include(other_client.email)
      end
    end

    shared_examples_for "A searchable & orderable collection" do |search_keys|
      search_keys.each do |search_key|
        context "#{search_key} search & ordering" do
          let(:search_target) { search_key == "email" ? client : client.profile }
          let(:sortables) { search_key == "email" ? users : users.map(&:profile) }

          it "yields the correct matching results for search" do
            get :index, params: { search_key => search_target[search_key.to_sym], :organization_id => organization.id }
            expect(resp["data"]["clientData"].first[search_key.camelize(:lower)]).to eq(search_target[search_key.to_sym])
          end

          it "sorts the result according to the param provided" do
            expected_response = sortables.pluck(search_key.to_sym).sort.reverse
            get :index, params: { "#{search_key}_desc" => "true", :organization_id => organization.id }
            expect(resp["data"]["clientData"].pluck(search_key.camelize(:lower))).to eq(expected_response)
          end
        end
      end
    end
    it_behaves_like "A searchable & orderable collection", %w[first_name last_name email]
  end

  describe "GET #show" do
    let!(:client) { FactoryBot.create(:users_client, organization: organization) }

    it "returns an http status of success" do
      post :show, params: { organization_id: organization, id: client }
      expect(response).to have_http_status(:success)
    end
  end

  describe "post #create" do
    let(:email) { "email123@demo.com" }
    let(:user_attributes) do
      FactoryBot.attributes_for(:users_client, email: email)
        .deep_transform_keys { |k| k.to_s.camelize(:lower) }
        .merge(password: "12345678", password_confirmation: "12345678")
    end
    let(:profile_params) { FactoryBot.attributes_for(:users_profile) }
    let(:profile_attributes) { profile_params.deep_transform_keys { |k| k.to_s.camelize(:lower) } }
    let(:attributes) { user_attributes.merge(profile_attributes) }
    let(:created_profile) { Users::ClientProfile.find_by(user_id: response_data.dig("data", "id")) }
    let(:created_settings) { Users::ClientSettings.find_by(user_id: response_data.dig("data", "id")) }
    let(:profile_response) do
      created_profile.attributes.slice("first_name", "last_name", "phone", "company_name").symbolize_keys
    end

    it "creates the user, profile and settings correctly", :aggregate_failures do
      post :create, params: { organization_id: organization, client: attributes }
      expect(response).to have_http_status(:success)
      expect(response_data.dig("data", "attributes", "email")).to eq(email)
      expect(profile_response).to eq(profile_params.except(:user))
      expect(created_settings.currency).to eq(Organizations::DEFAULT_SCOPE["default_currency"])
    end

    context "when params are incomplete" do
      it "responds with an ActionController::ParameterMissing error when params are missing" do
        expect do
          post :create, params: { organization_id: organization, client: attributes.except(:password) }
        end.to raise_error(ActionController::ParameterMissing)
      end
    end
  end

  describe "POST #agents" do
    let(:perform_request) { post :agents, params: { organization_id: organization, file: file } }
    let(:file) { fixture_file_upload("spec/fixtures/files/dummy.xlsx") }

    it_behaves_like "uploading request async"
  end

  describe "DELETE #destroy" do
    let(:user) { FactoryBot.create(:users_client, organization: organization) }
    let(:group) { FactoryBot.create(:groups_group, organization: organization) }
    let(:company) { FactoryBot.create(:companies_company, organization: organization) }

    before do
      FactoryBot.create(:groups_membership, group: group, member: user)
      FactoryBot.create(:companies_membership, company: company, client: user)
    end

    it "returns an http status of success" do
      delete :destroy, params: { organization_id: organization, id: user.id }
      expect(response).to have_http_status(:success)
    end

    it "deletes the users group membership" do
      delete :destroy, params: { organization_id: organization, id: user.id }
      expect(Groups::Membership.exists?(member: user)).to be false
    end

    it "deletes the users company memberships" do
      delete :destroy, params: { organization_id: organization, id: user.id }
      expect(Companies::Membership.where(client: user)).not_to exist
    end

    it "deletes the user" do
      delete :destroy, params: { organization_id: organization, id: user.id }
      expect(Users::Client.find_by(id: user.id)).to be(nil)
    end
  end
end
