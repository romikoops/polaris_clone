# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Themes", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:theme) { FactoryBot.create(:organizations_theme, organization_id: organization.id) }

  path "/v2/organizations/{organization_id}/theme" do
    get "Fetch theme information for organization" do
      tags "Theme"
      description "Fetch theme information for a given organization"
      operationId "getTheme"

      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"

      let(:organization_id) { organization.id }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   items: { "$ref" => "#/components/schemas/theme" }
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end
end
