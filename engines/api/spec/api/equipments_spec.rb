# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Equipments" do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy: legacy_tenant) }
  let(:itinerary) { FactoryBot.create(:legacy_itinerary, :default, tenant: legacy_tenant) }

  let!(:equipment) do
    [
      FactoryBot.create(:fcl_20_pricing, tenant: legacy_tenant, itinerary: itinerary),
      FactoryBot.create(:fcl_40_pricing, tenant: legacy_tenant, itinerary: itinerary)
    ]
  end

  let(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v1/equipments" do
    get "Fetch all available equipment" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :origin_nexus_id, in: :query, type: :string, schema: {type: :string},
                description: "the id of the origin"
      parameter name: :destination_nexus_id, in: :query, type: :string, schema: {type: :string},
                description: "the id of the destination"

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
