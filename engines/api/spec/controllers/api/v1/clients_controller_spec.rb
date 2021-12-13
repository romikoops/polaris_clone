# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::ClientsController, type: :controller do
    routes { Engine.routes }

    subject do
      request.headers["Authorization"] = token_header
      request_object
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:organization_group) { Groups::Group.create(organization: organization) }
    let!(:user) { FactoryBot.create(:users_user, email: "test@example.com") }

    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:perform_request) { subject }

    before do
      FactoryBot.create(:users_membership, organization: organization, user: user)
      FactoryBot.create(:groups_group, :default, organization: organization)
      FactoryBot.create(:companies_company, organization: organization, name: "default")
      ::Organizations.current_id = organization.id
      stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700")
        .to_return(status: 200, body: "", headers: {})
    end

    describe "GET #index" do
      before do
        FactoryBot.create_list(:users_client, 5, organization: organization)
      end

      context "when no sorting params passed" do
        let(:request_object) do
          get :index, params: { organization_id: organization.id }, as: :json
        end

        it "renders the list of users successfully" do
          perform_request
          aggregate_failures do
            expect(response).to be_successful
            expect(response_data).not_to be_empty
          end
        end
      end

      context "when sorting params passed" do
        let(:request_object) do
          get :index, params: { organization_id: organization.id, sort_by: "phone", direction: "asc" }, as: :json
        end

        it "renders the list of users successfully" do
          perform_request
          aggregate_failures do
            expect(response).to be_successful
            expect(response_data).not_to be_empty
          end
        end
      end

      context "when search params passed" do
        let!(:client) { FactoryBot.create(:users_client, organization: organization, profile: FactoryBot.build(:users_client_profile, first_name: "Bob")) }
        let(:request_object) do
          get :index, params: { organization_id: organization.id, query: client.profile.first_name[0..1] }, as: :json
        end

        it "renders the list of users successfully", :aggregate_failures do
          perform_request
          expect(response).to be_successful
          expect(response_data).not_to be_empty
        end
      end
    end

    describe "Get #show" do
      let(:org_user) { FactoryBot.create(:users_client, organization: organization) }
      let(:request_object) { get :show, params: { organization_id: organization.id, id: org_user.id }, as: :json }

      it "returns the requested client correctly", :aggregate_failures do
        perform_request
        %w[companyName email phone firstName lastName].each do |key|
          expect(response_data["attributes"]).to have_key(key)
        end
      end
    end

    describe "PATCH #update" do
      let(:client) { FactoryBot.create(:users_client, organization: organization) }
      let(:profile) { client.profile }

      context "when request is successful" do
        let(:request_object) do
          patch :update, params: { organization_id: organization.id,
                                   id: client.id,
                                   email: "bassam@itsmycargo.com",
                                   first_name: "Bassam", last_name: "Aziz",
                                   company_name: "ItsMyCargo",
                                   phone: "123123" }, as: :json
        end

        it "returns an http status of success" do
          perform_request
          expect(response).to be_successful
        end

        it "updates the user profile successfully" do
          perform_request
          expect(json.dig(:data, :attributes, :firstName)).to eq("Bassam")
        end

        it "updates the user email successfully" do
          perform_request
          expect(json.dig(:data, :attributes, :email)).to eq("bassam@itsmycargo.com")
        end
      end

      context "when update email request is invalid" do
        let(:request_object) do
          patch :update, params: { organization_id: organization,
                                   id: client.id,
                                   email: nil,
                                   first_name: "Bassam", last_name: "Aziz",
                                   company_name: "ItsMyCargo",
                                   phone: "123123" }, as: :json
        end

        it "returns with a 422 response" do
          perform_request
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns list of errors" do
          json = JSON.parse(perform_request.body)
          expect(json["error"]).to match_array(["Email can't be blank", "Email is invalid"])
        end
      end
    end

    describe "POST #create" do
      let(:user_info) do
        FactoryBot.attributes_for(:users_client, organization_id: organization.id)
          .merge(group_id: organization_group.id)
      end
      let(:profile_info) { FactoryBot.attributes_for(:users_profile) }
      let(:country) { FactoryBot.create(:legacy_country) }
      let(:address_info) do
        { street: "Brooktorkai", house_number: "7", city: "Hamburg", postal_code: "22047", country: country.name }
      end
      let(:request_object) do
        post :create, params: {
          organization_id: organization.id,
          **user_info,
          **profile_info,
          **address_info
        }, as: :json
      end
      let(:user_groups) do
        OrganizationManager::GroupsService.new(target: client, organization: organization).fetch
      end
      let(:client) { Users::Client.find_by(email: user_info[:email]) }

      context "when request is successful" do
        it "returns http status of success" do
          perform_request
          expect(response).to have_http_status(:success)
        end

        it "creates the user successfully" do
          perform_request
          expect(Users::Client.find_by(email: user_info[:email])).not_to be_nil
        end
      end

      context "when creating clients without role" do
        let(:request_object) do
          post :create, params: {
            organization_id: organization.id, **user_info, **profile_info, **address_info
          }
        end

        it "assigns the default role (shipper) to the new user" do
          perform_request

          expect(client.organization_id).to eq(user_info[:organization_id])
        end
      end

      context "when creating clients without group_id params" do
        let(:user_info) { FactoryBot.attributes_for(:users_client, organization_id: organization.id) }

        it "assigns the default group of the organization to the new user membership" do
          perform_request
          expect(user_groups.pluck(:name)).to include("default")
        end
      end

      context "when request is unsuccessful (bad or missing data)" do
        let(:request_object) do
          post :create, params: {
            organization_id: organization.id, client: { **user_info, **profile_info, **address_info, email: nil }
          }, as: :json
        end

        it "returns with a 400 response" do
          perform_request
          expect(response).to have_http_status(:bad_request)
        end

        it "returns list of errors" do
          json = JSON.parse(perform_request.body)
          expect(json["error"]).to include("Validation failed: Email can't be blank, Email is invalid")
        end
      end
    end

    describe "DELETE #destroy" do
      let(:client) { FactoryBot.create(:user_services_client, organization: organization) }
      let!(:profile) { Users::ClientProfile.find_by(user_id: client.id) }
      let(:organization_user) { Users::Client.with_deleted.find_by(id: client.id) }
      let(:company) { FactoryBot.create(:companies_company, organization: organization) }
      let(:request_object) do
        delete :destroy,
          params: { organization_id: organization.id,
                    id: client.id },
          as: :json
      end

      context "when request is successful" do
        it "deletes the client successfully" do
          perform_request
          expect(response).to be_successful
        end

        it "deletes the profile successfully" do
          perform_request
          expect(profile).to be_present
        end

        it "deletes the users group membership" do
          perform_request
          expect(Groups::Membership.exists?(member: client)).to be false
        end

        it "deletes the user's company membership" do
          perform_request
          expect(Companies::Membership.where(client: client)).not_to exist
        end

        it "deletes the authentication user successfully" do
          perform_request
          client.reload
          expect(client).to be_deleted
        end

        it "deletes the organization user successfully" do
          perform_request
          user.reload
          expect(organization_user).to be_deleted
        end
      end

      context "when request cannot find a user" do
        before do
          client.destroy!
        end

        it "returns with a 404 response" do
          perform_request
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
