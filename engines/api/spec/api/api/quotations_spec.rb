# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Quotations", type: :request, swagger_doc: "v1/swagger.json" do
  include_context "journey_pdf_setup"
  include_context "complete_route_with_trucking"
  let(:load_type) { "container" }
  let(:cargo_classes) { ["fcl_20"] }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:source) { FactoryBot.create(:application) }
  let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
  let(:origin) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode) }
  let(:destination) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode) }
  let(:carta_double) { double("Carta::Api") }

  before do
    allow(controller).to receive(:doorkeeper_application).and_return(FactoryBot.create(:application))
    allow(Carta::Api).to receive(:new).and_return(carta_double)
    allow(carta_double).to receive(:suggest).with(query: origin_hub.hub_code).and_return(origin)
    allow(carta_double).to receive(:suggest).with(query: destination_hub.hub_code).and_return(destination)
    ::Organizations.current_id = organization.id
    organization.scope.update(content: {base_pricing: true})
  end

  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v1/organizations/{organization_id}/quotations" do
    post "Create new quotation" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :quote, in: :body, schema: {
        type: :object,
        properties: {
          organization_id: {type: :string},
          quote: {
            type: :object,
            properties: {
              selected_date: {type: :date},
              organization_id: {type: :string},
              user_id: {type: :string},
              origin: {type: :string},
              destination: {type: :string}
            }
          },
          shipment_info: {
            type: :object,
            properties: {
              cargo_item_attributes: {type: :object, properties: {}},
              containers_attributes: {type: :object, properties: {}},
              trucking_info: {
                type: :object,
                properties: {}
              }
            }
          }
        }
      }

      response "200", "successful operation" do
        let(:quote) do
          {
            organization_id: organization.id,
            quote: {
              selected_date: Time.zone.now,
              user_id: user.id,
              load_type: "container",
              origin: {nexus_id: origin_hub.nexus_id},
              destination: {nexus_id: destination_hub.nexus_id}
            },
            shipment_info: {
              trucking_info: {}
            }
          }
        end

        run_test!
      end
    end
  end

  path "/v1/organizations/{organization_id}/quotations/{id}" do
    get "Fetch existing quotation" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :id, in: :path, type: :string, schema: {type: :string}
      parameter name: :organization_id, in: :query, type: :string, schema: {type: :string}

      response "200", "successful operation" do
        let(:organization_id) { organization.id }
        let(:id) { query.id }

        run_test!
      end
    end
  end

  path "/v1/organizations/{organization_id}/quotations/{id}/download" do
    post "Download quotation as PDF" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :id, in: :path, type: :string, schema: {type: :string}
      parameter name: :organization_id, in: :query, type: :string, schema: {type: :string}
      parameter name: :format, type: :string, in: :query, description: "The desired download format (pdf/xlsx)"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          tenders: {
            type: :array,
            items: {
              type: :string
            }
          }
        }
      }

      response "200", "successful operation" do
        let(:organization_id) { organization.id }
        let(:id) { query.id }
        let(:params) { {tenders: [result.id], format: format} }
        let(:format) { "pdf" }

        run_test!
      end
    end
  end
end
