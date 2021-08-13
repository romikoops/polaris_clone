# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Schedules", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly") }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:result) { FactoryBot.create(:journey_result) }
  let(:tender) do
    FactoryBot.create(:quotations_tender, itinerary: itinerary, tenant_vehicle: tenant_vehicle, load_type: "cargo_item")
  end

  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    [1, 3, 5, 10].map do |num|
      base_date = num.days.from_now
      FactoryBot.create(:legacy_trip,
        itinerary: itinerary,
        tenant_vehicle: tenant_vehicle,
        closing_date: base_date - 4.days,
        start_date: base_date,
        end_date: base_date + 30.days)
    end
  end

  path "/v1/organizations/{organization_id}/quotations/{quotation_id}/schedules/{id}" do
    get "Fetch available schedules" do
      tags "Quote"
      description "Fetch available schedules"
      operationId "getSchedule"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :quotation_id, in: :path, type: :string, description: "The quotation ID"
      parameter name: :id, in: :path, type: :string, description: "The quotation ID"

      let(:quotation_id) { tender.quotation_id }
      let(:id) { tender.id }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string },
                       type: { type: :string },
                       attributes: {
                         type: :object,
                         properties: {
                           carrier: { type: :string },
                           closing: { type: :string },
                           end: { type: :string },
                           service: { type: :string },
                           start: { type: :string },
                           tenderId: { type: :string },
                           vessel: { type: :string, nullable: true },
                           voyageCode: { type: :string, nullable: true }
                         },
                         required: %w[carrier closing end service start tenderId vessel voyageCode]
                       }
                     },
                     required: %w[id type attributes]
                   }
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end

  path "/v1/organizations/{organization_id}/itineraries/{id}/schedules/enabled" do
    get "Fetch status of schedules" do
      tags "Quote"
      description "Fetch status of schedules"
      operationId "getScheduleEnabled"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :id, in: :path, type: :string, description: "The itinerary ID"

      let(:id) { itinerary.id }
      let(:organization_id) { organization.id }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     enabled: { type: :boolean }
                   },
                   required: ["enabled"]
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end

  path "/v2/organizations/{organization_id}/results/{result_id}/schedules" do
    get "Fetch schedules for a given result" do
      tags "Schedule"
      description "Fetch all valid schedules for result"
      operationId "getSchedules"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :result_id, in: :path, type: :string, description: "The result ID for which the schedules are to be fetched"

      let(:result_id) { result.id }
      let(:organization_id) { organization.id }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: { "$ref" => "#/components/schemas/schedule" }
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end
end
