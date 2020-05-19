# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Users" do
  let(:role) { FactoryBot.create(:legacy_role) }
  let(:legacy_user) { FactoryBot.create(:legacy_user, role: role) }
  let(:user) { FactoryBot.create(:tenants_user, legacy: legacy_user) }
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
                         tenantId: {type: :string},
                         firstName: {type: :string},
                         lastName: {type: :string},
                         phone: {type: :string},
                         companyName: {type: :string},
                         role: {type: :string}
                       },
                       required: %w[email tenantId firstName lastName phone companyName role]
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
