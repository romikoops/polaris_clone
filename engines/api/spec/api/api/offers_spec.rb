# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Offers", type: :request, swagger: true do

  let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:token_header) { "Bearer #{access_token.token}" }
  let(:query) { FactoryBot.create(:journey_query) }
  let(:result) { FactoryBot.create(:journey_result, query: query) }
  let(:offer_obj) { FactoryBot.create(:journey_offer, query: query, line_item_sets: result.line_item_sets) }
  let(:source) { FactoryBot.create(:application, name: "siren") }

  let(:access_token) do
    FactoryBot.create(:access_token,
      resource_owner_id: user.id,
      scopes: "public",
      application: source)
  end
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v2/organizations/{organization_id}/offers" do

    post "Create new offer" do
      tags "Offer"
      description <<~DOC
        Create a new offer. To be able to download quotation results as a PDF, first the offer must be created with results that are to be included in the offer.
        Creating a new offer with the selected result IDs allows the backend system to generate a downloadable PDF for these results.
      DOC
      operationId "createOffer"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :offer, in: :body, schema: {
        type: :object,
        properties: {
          resultIds: {
            description: "array of the ids of the results to be included in the offer",
            type: :array,
            items: {
              type: :string
            }
          }
        },
        required: ["resultIds"]
      }

      response "201", "successful operation" do
        let(:offer) { {resultIds: [result.id]} }

        before { allow(Wheelhouse::OfferBuilder).to receive(:offer).and_return(offer_obj) }

        schema type: :object,
               properties: {
                 data: {"$ref" => "#/components/schemas/offer"}
               },
               required: ["data"]

        run_test!
      end

      response 422, 'unprocessable entity' do
        let(:offer) { {resultIds: []} }

        schema '$ref' => '#/components/schemas/errors'

        run_test!
      end

      response 404, "results not found" do
        let(:offer) { {resultIds: ["123"]} }

        schema '$ref' => '#/components/schemas/errors'

        run_test!
      end


    end
  end
end
