# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Widgets" do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:users_user) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }
  let(:widget) { {widget: {name: "Test Widget", data: "Test widget data", order: 0}} }

  before do
    Organizations::Membership.create(user: user, organization: organization, role: "admin")
  end

  path "/v1/organizations/{organization_id}/widgets" do
    get "Fetch all widgets for organization" do
      tags "Widgets"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {"$ref" => "#/components/schemas/widget"}
                 }
               },
               required: ["data"]

        run_test!
      end
    end

    post "Create a new widget" do
      tags "Widget"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :widget, in: :body, schema: {
        type: :object,
        properties: {
          widget: {"$ref" => "#/components/schemas/widget"}
        }
      }

      response "201", "successful operation" do
        run_test!
      end

      response "422", "Unprocessable entity" do
        let(:widget) { {widget: {name: nil, data: "", order: 0}} }

        run_test!
      end
    end
  end

  path "/v1/organizations/{organization_id}/widgets/{id}" do
    patch "Update a widget" do
      tags "Widget"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :id, in: :path, type: :string, description: "The ID of the widget to be updated"
      parameter name: :widget, in: :body, schema: {
        type: :object,
        properties: {
          widget: {"$ref" => "#/components/schemas/widget"}
        }
      }
      let(:id) { FactoryBot.create(:cms_data_widget).id }

      response "200", "successful operation" do
        let(:widget) { {widget: {name: "New widget name", data: "Test Data", order: 0}} }

        run_test!
      end

      response "422", "Unprocessable entity" do
        let(:widget) { {widget: {name: nil, data: "", order: 0}} }

        run_test!
      end
    end

    delete "Delete a widget" do
      tags "Widget"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :id, in: :path, type: :string, description: "The ID of the widget to be deleted"

      let(:id) { FactoryBot.create(:cms_data_widget).id }

      response "204", "successful deletion" do
        run_test!
      end
    end
  end
end
