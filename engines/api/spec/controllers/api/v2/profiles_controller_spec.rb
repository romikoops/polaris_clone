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
    let!(:client) { FactoryBot.create(:users_client, email: "test@example.com", profile: client_profile, settings: client_settings, organization: organization) }
    let(:client_profile) { FactoryBot.build(:users_client_profile) }
    let(:client_settings) { FactoryBot.build(:users_client_settings) }

    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: client.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:perform_request) { subject }

    before do
      ::Organizations.current_id = organization.id
    end

    describe "Get #show" do
      let(:request_object) { get :show, params: { organization_id: organization.id }, as: :json }

      before { perform_request }

      context "when successful" do
        it "returns 200" do
          expect(response.status).to eq 200
        end

        it "returns the profile" do
          expect(response_data["attributes"]).to eq({
            "email" => client.email, "firstName" => client_profile.first_name,
            "lastName" => client_profile.last_name, "phone" => client_profile.phone,
            "currency" => client_settings.currency, "language" => client_settings.language, "locale" => client_settings.locale
          })
        end
      end

      context "when profile is deleted" do
        let(:client_profile) { FactoryBot.build(:users_client_profile, deleted_at: Time.zone.now) }

        it "returns 200" do
          expect(response.status).to eq 200
        end

        it "returns the profile" do
          expect(response_data["attributes"]).to eq({
            "email" => nil, "firstName" => "",
            "lastName" => "", "phone" => nil,
            "currency" => nil, "language" => nil, "locale" => nil
          })
        end
      end
    end

    describe "PATCH #update" do
      let(:request_object) do
        patch :update, params: {
          organization_id: organization.id,
          profile: profile_params
        }, as: :json
      end

      context "when request is successful" do
        let(:expected_data) do
          {
            "email" => "updated@itsmycargo.com",
            "firstName" => "new first name",
            "lastName" => "new last name",
            "phone" => client_profile.phone,
            "language" => "en-GB",
            "locale" => "es-ES",
            "currency" => "USD"
          }
        end
        let(:profile_params) do
          {
            email: expected_data["email"],
            firstName: expected_data["firstName"],
            lastName: expected_data["lastName"],
            currency: expected_data["currency"],
            language: expected_data["language"],
            locale: expected_data["locale"],
            password: "NEWPASSWORD"
          }
        end

        before do
          FactoryBot.create(:treasury_exchange_rate, from: "USD")
        end

        it "returns an http status of success" do
          perform_request
          expect(response).to be_successful
        end

        it "updates the user profile successfully" do
          perform_request

          expect(response_data["attributes"]).to eq(expected_data)
        end

        it "updates the user settings successfully", :aggregate_failures do
          perform_request
          client_settings.reload
          expect(client_settings.language).to eq(expected_data["language"])
          expect(client_settings.locale).to eq(expected_data["locale"])
          expect(client_settings.currency).to eq(expected_data["currency"])
        end

        it "updates the user email and password successfully" do
          perform_request

          expect(Users::Client.global.authenticate(expected_data["email"].dup, "NEWPASSWORD")).to eq(client)
        end
      end

      context "when update email request is invalid" do
        let(:other_client) { FactoryBot.create(:users_client, organization: organization) }
        let(:profile_params) do
          {
            email: other_client.email
          }
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

      context "when update currency request is invalid" do
        let(:profile_params) do
          {
            currency: "123"
          }
        end

        it "returns with a 422 response" do
          perform_request
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns list of errors" do
          expect(JSON.parse(perform_request.body)).to eq("currency" => ["Invalid currency. Refer to ISO 4217 for list of valid codes"])
        end
      end
    end
  end
end
