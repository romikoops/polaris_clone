# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Users", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_user, organization_id: organization.id) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v1/me" do
    get "Fetch information of current user" do
      tags "Users"
      description "Fetch information of current user"
      operationId "getCurrentUser"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: {
                       type: :string
                     },
                     type: {
                       type: :string
                     },
                     attributes: {
                       type: :object,
                       properties: {
                         email: {
                           type: :string,
                           description: %(User's primary email address. This is
                             validated address that can be used for reaching out.)
                         },
                         organizationId: {
                           description: %(If current user is client, this is the
                             organization user account is linked with.),
                           type: :string, nullable: true
                         },
                         firstName: {
                           description: "User's first name, usually given name.",
                           type: :string
                         },
                         lastName: {
                           description: "User's last name, usually family name.",
                           type: :string
                         },
                         phone: {
                           description: %(User's phone number if given. This generic
                             information that is not validated or structured.),
                           type: :string, nullable: true
                         },
                         companyName: {
                           type: :string
                         }
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

  path "/v2/users/validate" do
    get "Validate user for the specified email" do
      tags "Login"
      description "Verify user for the email"
      operationId "verify_user"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :email, in: :query, type: :string, description: "email of the users_user"

      let(:email) { user.email }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: {
                       type: :string
                     },
                     type: {
                       type: :string
                     },
                     attributes: {
                       type: :object,
                       properties: {
                         firstName: {
                           description: "User's first name, usually given name.",
                           type: :string
                         },
                         authMethods: {
                           description: "auth methods for users",
                           type: :array
                         },
                         samlIntegrations: {
                           description: %(information required to support SAML workflow from frontend such button and redirection url),
                           type: :array
                         }
                       },
                       required: %w[firstName authMethods samlIntegrations]
                     }
                   },
                   required: %w[id type attributes]
                 }
               },
               required: ["data"]
        run_test!
      end
    end
  end
end
