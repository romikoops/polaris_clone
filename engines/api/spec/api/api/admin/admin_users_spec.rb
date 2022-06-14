# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "AdminUsers", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let!(:user) { FactoryBot.create(:users_user).tap { |users_user| FactoryBot.create(:users_membership, organization: organization, user: users_user) } }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    Organizations.current_id = organization_id
  end

  path "/v2/organizations/{organization_id}/admin/users" do
    post "Create new admin users" do
      tags "AdminUsers"
      description "Create new admin users"
      operationId "createAdminUsers"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :admin_user_params, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, description: "The email address of the admin user" },
          role: { type: :string, description: "The role of the admin user which is `admin`, `owner` and `user`" },
          profile: {
            type: :object,
            properties: {
              firstName: { type: :string, description: "first name of the admin" },
              lastName: { type: :string, description: "last name of the admin" }
            }
          },
          settings: {

          }
        }
      }
      let(:admin_user_params) do
        {
          admin: {
            email: "test@imc.com",
            role: "admin",
            profile: {
              firstName: "John",
              lastName: "Doe"
            }
          }
        }
      end

      response "201", "successful admin_user create" do
        schema type: :object,
          properties: {
            data: {
              "$ref" => "#/components/schemas/admin_user"
            }
          },
          required: ["data"]
        run_test!
      end

      response "400", "bad request (missing params)" do
        let(:admin_user_params) do
          {
            admin: {
              email: "test@imc.com",
              role: "admin",
              profile: {
                lastName: "Doe"
              }
            }
          }
        end
        run_test!
      end

      response "422", "invalid request (duplicate record)" do
        let(:admin_user_params) do
          {
            admin: {
              email: user.email,
              role: "admin",
              profile: {
                firstName: "John",
                lastName: "Doe"
              }
            }
          }
        end
        run_test!
      end
    end
  end

  path "/v2/organizations/{organization_id}/admin/users/{user_id}" do
    put "Update an admin user" do
      tags "AdminUsers"
      description "Update a specific admin user"
      operationId "updateAdminUser"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      let(:existing_user) { FactoryBot.create(:users_user).tap { |users_user| FactoryBot.create(:users_membership, organization: organization, user: users_user) } }
      let(:user_id) { existing_user.id }

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :user_id, in: :path, type: :string, description: "The admin user id"
      parameter name: :admin_user_params, in: :body, schema: {
        type: :object,
        properties: {
          admin: {
            type: :object,
            properties: {
              email: { type: :string, description: "The email address of the admin user" },
              role: { type: :string, description: "The role of the admin user which is `admin`, `owner` and `user`" },
              profile: {
                type: :object,
                properties: {
                  firstName: { type: :string, description: "first name of the admin" },
                  lastName: { type: :string, description: "last name of the admin" }
                }
              },
              settings: {}
            }
          }
        }
      }

      response "200", "successful operation" do
        let(:admin_user_params) do
          {
            admin: {
              email: "test@imc.com",
              role: "admin",
              profile: {
                firstName: "John Edited",
                lastName: "Doe"
              }
            }
          }
        end

        schema type: :object,
          properties: {
            data: {
              "$ref" => "#/components/schemas/admin_user"
            }
          },
          required: ["data"]

        run_test!
      end

      response "400", "Bad Request" do
        let(:admin_user_params) do
          {
            admin: {
              email: "test@imc.com",
              role: "admin",
              profile: {
                lastName: "Doe"
              }
            }
          }
        end

        run_test!
      end
    end

    delete "Delete an admin user" do
      tags "AdminUsers"
      description "Delete a specific admin user"
      operationId "deleteAdminUser"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :user_id, in: :path, type: :string, description: "The current admin user id"

      let(:existing_user) { FactoryBot.create(:users_user).tap { |users_user| FactoryBot.create(:users_membership, organization: organization, user: users_user) } }
      let(:user_id) { existing_user.id }

      response "200", "successful operation" do
        run_test!
      end

      response "422", "Unprocessable Entity" do
        let(:existing_user) { FactoryBot.create(:users_client, organization_id: organization_id) }
        run_test!
      end
    end
  end
end
