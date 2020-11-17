# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Equipments" do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization_id: organization.id) }
  let(:itinerary) { FactoryBot.create(:legacy_itinerary, :default, organization: organization) }

  let!(:equipment) do
    [
      FactoryBot.create(:fcl_20_pricing, organization: organization, itinerary: itinerary),
      FactoryBot.create(:fcl_40_pricing, organization: organization, itinerary: itinerary)
    ]
  end

  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v1/organizations/{organization_id}/equipments" do
    get "Fetch all available equipment" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :origin_nexus_id, in: :query, type: :string, schema: {type: :string},
                description: "the id of the origin"
      parameter name: :destination_nexus_id, in: :query, type: :string, schema: {type: :string},
                description: "the id of the destination"

      let(:organization_id) { organization.id }
      let(:origin_nexus_id) { itinerary.hubs[0].nexus_id }
      let(:destination_nexus_id) { itinerary.hubs[1].nexus_id }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {type: :string}
                 }
               },
               required: ["data"]

        run_test! do
          expect(response_data).to eq equipment.map(&:cargo_class)
        end
      end

      response "401", "Invalid Credentials" do
        let(:Authorization) { "Basic deadbeef" }

        run_test!
      end
    end
  end
end
