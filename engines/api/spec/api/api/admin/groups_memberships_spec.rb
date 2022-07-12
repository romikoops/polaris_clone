# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "GroupsMemberships", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let!(:user) { FactoryBot.create(:users_user).tap { |users_user| FactoryBot.create(:users_membership, organization: organization, user: users_user) } }
  let(:company) { FactoryBot.create(:companies_company, organization: organization) }
  let(:company_id) { company.id }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }
  let(:groups_group) { FactoryBot.create(:groups_group, organization: organization, name: "demo_group") }
  let(:groups_membership) { Api::GroupsMembership.create(group: groups_group, member: company) }

  before do
    Organizations.current_id = organization_id
    groups_membership
  end

  path "/v2/organizations/{organization_id}/admin/companies/{company_id}/groups_memberships" do
    get "Fetch all groups memberships for a company" do
      tags "GroupsMemberships"
      description "Fetch all groups memberships for an organization."
      operationId "getGroupsMemberships"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :company_id, in: :path, type: :string, description: "The company ID"
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
        description: "The attribute of the groups memberships and its related models to search through",
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
                  memberType: {
                    type: :string,
                    description: "Type of the member with which the membership exists ex: `Companies::Company`, `Groups::Group` or `Users::Clients`"
                  },
                  memberId: {
                    type: :string,
                    description: "ID of the above defined member types"
                  },
                  groupId: {
                    type: :string,
                    description: "The Group ID"
                  },
                  priority: {
                    type: :string,
                    description: "Priority integer of the group of the company"
                  },
                  groupName: {
                    type: :string,
                    description: "Name of the group for which the membership belong to"
                  }
                }
              }
            }
          },
          required: ["data"]
        run_test!
      end
    end

    post "Create new groups membership" do
      tags "GroupsMembership"
      description "Create new groups membership"
      operationId "createGroupsMembership"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :company_id, in: :path, type: :string, description: "The company ID"

      parameter name: :groups_membership_params, in: :body, schema: {
        type: :object,
        properties: {
          groupId: { type: :string, description: "ID of the group for which the membership needs to be created" }
        }
      }
      let(:default_group) { FactoryBot.create(:groups_group, organization: organization, name: "default_group") }

      let(:groups_membership_params) do
        {
          groupMembership: {
            groupId: default_group.id
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
                  memberType: {
                    type: :string,
                    description: "Type of the member with which the membership exists ex: `Companies::Company`, `Groups::Group` or `Users::Clients`"
                  },
                  memberId: {
                    type: :string,
                    description: "ID of the above defined member types"
                  },
                  groupId: {
                    type: :string,
                    description: "The Group ID"
                  },
                  priority: {
                    type: :string,
                    description: "Priority integer of the group of the company"
                  },
                  groupName: {
                    type: :string,
                    description: "Name of the group for which the membership belong to"
                  }
                }
              }
            }
          },
          required: ["data"]
        run_test!
      end
    end
  end

  path "/v2/organizations/{organization_id}/admin/companies/{company_id}/groups_memberships/{id}" do
    delete "Destroy a specific groups membership" do
      tags "GroupsMembership"
      description "Deletes a groups membership."
      operationId "deleteGroupsMembership"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :company_id, in: :path, type: :string, description: "The company ID"
      parameter name: :id, in: :path, type: :string, description: "groups membership ID"

      response "200", "successful operation" do
        let(:id) { groups_membership.id }

        run_test!
      end

      response "422", "Invalid group membership ID" do
        let(:id) { "abc" }

        run_test!
      end
    end
  end
end
