# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Users" do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization_id: organization.id) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    FactoryBot.create(:profiles_profile, user_id: user.id)
  end

  path "/v1/me" do
    get "Fetch information of current user" do
      tags "Users"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: {type: :string},
                     type: {type: :string},
                     attributes: {
                       type: :object,
                       properties: {
                         email: {type: :string},
                         organizationId: {type: :string},
                         firstName: {type: :string},
                         lastName: {type: :string},
                         phone: {type: :string},
                         companyName: {type: :string},
                       },
                       required: %w[email organizationId firstName lastName phone companyName]
                     }
                   },
                   required: %w[id type attributes]
                 }
               },
               required: ["data"]

        run_test!
      end

      response "401", "Invalid Credentials" do
        let(:Authorization) { "Basic deadbeef" }

        run_test!
      end
    end
  end
end
