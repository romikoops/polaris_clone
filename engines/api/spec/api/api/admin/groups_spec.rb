# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Groups", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let!(:user) { FactoryBot.create(:users_user).tap { |users_user| FactoryBot.create(:users_membership, organization: organization, user: users_user) } }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    Organizations.current_id = organization_id
  end

  path "/v2/organizations/{organization_id}/admin/groups" do
    get "Fetch all groups for an organization" do
      tags "Groups"
      description "Fetch all groups for an organization."
      operationId "getGroups"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :page, in: :query, type: :number, description: "Page number"
      parameter name: :perPage, in: :query, type: :number, description: "Results per page"
      parameter name: :sortBy,
        in: :query,
        type: :string,
        description: "The attribute by which to sort admin users",
        enum: %w[
          name_asc
        ]

      parameter name: :direction,
        in: :query,
        type: :string,
        description: "The defining whether the sorting is ascending or descending",
        enum: %w[
          asc
          desc
        ]
      parameter name: :searchBy,
        in: :query,
        type: :string,
        description: "The attribute of the admin users and its related models to search through",
        enum: %w[name]

      parameter name: :searchQuery,
        in: :query,
        type: :string,
        description: "The value we want to use in our search"

      let(:sortBy) { "name" }
      let(:direction) { "asc" }
      let(:page) { 1 }
      let(:perPage) { 10 }
      let(:searchBy) { "name" }
      let(:searchQuery) { "demo_group" }
      let(:groups_group) { FactoryBot.create(:groups_group, organization: organization, name: "demo_group") }

      response "200", "successful operation" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: {
                    type: :UUID,
                    description: "ID of the group"
                  },
                  name: {
                    type: :string,
                    description: "Name of the group"
                  },
                  organization_id: {
                    type: :string,
                    description: "Organization ID for which the group belong to"
                  }
                }
              }
            }
          },
          required: ["data"]
        run_test!
      end
    end

    post "Create new group" do
      tags "Groups"
      description "Create new group"
      operationId "createGroups"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :group_params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, description: "Name of the group" }
        }
      }
      let(:group_params) do
        {
          group: {
            name: "default_group"
          }
        }
      end

      response "201", "successful group create" do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              items: {
                type: :object,
                properties: {
                  id: {
                    type: :UUID,
                    description: "ID of the group"
                  },
                  name: {
                    type: :string,
                    description: "Name of the group"
                  },
                  organization_id: {
                    type: :string,
                    description: "Organization ID for which the group belong to"
                  }
                }
              }
            }
          },
          required: ["data"]
        run_test!
      end

      response "400", "bad request (missing params)" do
        let(:group_params) do
          {
            group: {
              name: ""
            }
          }
        end
        run_test!
      end
    end
  end
end
