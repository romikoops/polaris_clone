# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Organization", type: :request, swagger: true do
  let(:user) { FactoryBot.create(:users_user) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:Referer) { "http://#{organization.slug}.lvh.me" }

  path "/v1/organization" do
    get "Fetch current organization" do
      tags "Organization"
      description <<~DOC
        Fetch information of the current organization, automatically detected by the
        requester domain (referrer).

        Current organization is detected automatically based on the following hierachy:
          1. Referrer domain as is, e.g. yourdemo.itsmycargo.shop
          2. Slug as subdomain, e.g. yourdemo.lvh.me
      DOC
      operationId "getOrganization"

      consumes "application/json"
      produces "application/json"

      parameter name: :Referer, in: :header, type: :string, description: "HTTP Referrer"

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {"$ref" => "#/components/schemas/organization"}
               },
               required: ["data"]

        run_test! do
          json_response = JSON.parse(response.body)
          expect(json_response.dig("data", "id")).to eq organization.id
        end
      end

      response "404", "Not Found" do
        let(:Referer) { "https://deadbeef.nullisland.io" }

        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 message: { type: :string },
                 status: { type: :string },
                 code: { type: :number }
               },
               required: %w[success message status code]

        run_test! do
          json_response = JSON.parse(response.body)
          expect(json_response["status"]).to eq "not_found"
        end
      end
    end
  end
end
