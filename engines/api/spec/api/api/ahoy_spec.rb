# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Ahoy API", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }

  path "/v1/organizations/{organization_id}/ahoy" do
    get "Fetch Settings" do
      tags "Ahoy"
      description "Fetch settings for Ahoy widget."
      operationId "getAhoy"
      produces "application/json"
      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 endpoint: {
                   description: "Endpoint url that Ahoy will redirect to start the booking process",
                   type: :string
                 },
                 pre_carriage: {
                   description: "Determines if pre-carriage is enabled",
                   type: :boolean
                 },
                 on_carriage: {
                   description: "Determines if on-carriage is enabled",
                   type: :boolean
                 },
                 modes_of_transport: {
                   description: "Supported modes of transports",
                   type: :object,
                   properties: {
                     air: {
                       description: "Supported cargo types for Air Cargo",
                       type: :object,
                       properties: {
                         fcl: {
                           description: "Determines if FCL is supported",
                           type: :boolean
                         },
                         lcl: {
                           description: "Determines if LCL is supported",
                           type: :boolean
                         }
                       }, required: ["fcl", "lcl"]
                     },
                     rail: {
                       description: "Supported cargo types for Rail Cargo",
                       type: :object, properties: {
                         fcl: {
                           description: "Determines if FCL is supported",
                           type: :boolean
                         },
                         lcl: {
                           description: "Determines if LCL is supported",
                           type: :boolean
                         }
                       }, required: ["fcl", "lcl"]
                     },
                     ocean: {
                       description: "Supported cargo types for Ocean Cargo",
                       type: :object, properties: {
                         fcl: {
                           description: "Determines if FCL is supported",
                           type: :boolean
                         },
                         lcl: {
                           description: "Determines if LCL is supported",
                           type: :boolean
                         }
                       }, required: ["fcl", "lcl"]
                     },
                     truck: {
                       description: "Supported cargo types for Trucking Cargo",
                       type: :object, properties: {
                         fcl: {
                           description: "Determines if FCL is supported",
                           type: :boolean
                         },
                         lcl: {
                           description: "Determines if LCL is supported",
                           type: :boolean
                         }
                       }, required: ["fcl", "lcl"]
                     }
                   }, required: ["air", "rail", "ocean", "truck"]
                 }
               },
               required: ["endpoint", "pre_carriage", "on_carriage", "modes_of_transport"]

        run_test!
      end

      response "404", "Invalid Customer UUID" do
        let(:organization_id) { "invalid" }

        run_test!
      end
    end
  end
end
