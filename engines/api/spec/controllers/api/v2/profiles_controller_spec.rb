# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ProfilesController, type: :controller do
    routes { Engine.routes }

    subject do
      request.headers["Authorization"] = token_header
      request_object
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:client) { FactoryBot.create(:users_client, email: "test@example.com", organization: organization) }
    let(:profile) { client.profile }

    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: client.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:perform_request) { subject }

    before do
      ::Organizations.current_id = organization.id
    end

    describe "Get #show" do
      let(:request_object) { get :show, params: { organization_id: organization.id }, as: :json }
      let(:expected_data) do
        {
          "email" => client.email,
          "firstName" => profile.first_name,
          "lastName" => profile.last_name,
          "phone" => profile.phone
        }
      end

      context "when successful" do
        it "returns 200" do
          perform_request

          expect(response.status).to eq 200
        end

        it "returns the profile" do
          perform_request

          expect(response_data["attributes"]).to eq expected_data
        end
      end
    end

    describe "PATCH #update" do
      context "when request is successful" do
        let(:expected_data) do
          {
            "email" => "updated@itsmycargo.com",
            "firstName" => "new first name",
            "lastName" => "new last name",
            "phone" => profile.phone
          }
        end

        let(:request_object) do
          patch :update, params: {
            organization_id: organization.id,
            profile: {
              email: expected_data["email"],
              firstName: expected_data["firstName"],
              lastName: expected_data["lastName"],
              password: "NEWPASSWORD"
            }
          }, as: :json
        end

        it "returns an http status of success" do
          perform_request
          expect(response).to be_successful
        end

        it "updates the user profile successfully" do
          perform_request

          expect(response_data["attributes"]).to eq(expected_data)
        end

        it "updates the user email and password successfully" do
          perform_request

          expect(Users::Client.global.authenticate(expected_data["email"].dup, "NEWPASSWORD")).to eq(client)
        end
      end

      context "when update email request is invalid" do
        let(:other_client) { FactoryBot.create(:users_client, organization: organization) }
        let(:request_object) do
          patch :update, params: { organization_id: organization.id, profile: { email: other_client.email } }, as: :json
        end

        it "returns with a 422 response" do
          perform_request
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns list of errors" do
          json = JSON.parse(perform_request.body)
          expect(json["error"]).to match_array(["Email has already been taken"])
        end
      end
    end
  end
end
