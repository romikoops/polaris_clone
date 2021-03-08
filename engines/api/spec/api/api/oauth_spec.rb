# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "OAuth", type: :request, swagger: true do
  let(:user) { FactoryBot.create(:users_user) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/oauth/token/info" do
    get "Fetch information of current token" do
      tags "Authentication"
      description "Fetch information of current token"
      operationId "getTokenInfo"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 access_token: {
                   type: :string,
                   description: "Token used to access this endpoint"
                 },
                 token_type: {
                   type: :string,
                   description: "Type of the token (always Bearer)"
                 },
                 scope: {
                   type: :string,
                   description: "OAuth scopes of the token."
                 },
                 created_at: {
                   type: :number,
                   description: "Timestamp when token was created."
                 }
               },
               required: %w[access_token token_type scope created_at]

        run_test! do
          result = JSON.parse(response.body)
          expect(result["access_token"]).to eq access_token.token
        end
      end

      response "401", "Invalid Credentials" do
        let(:Authorization) { "Basic deadbeef" }

        schema type: :object,
               properties: {
                 error: {
                   type: :string,
                   description: "Error code describing the encountered error."
                 },
                 error_description: {
                   type: :string,
                   description: "Detailed description of the error occured."
                 }
               },
               required: %w[error error_description]

        run_test!
      end
    end
  end
end
