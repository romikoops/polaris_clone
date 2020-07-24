# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Quotations" do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:organizations_user, :with_profile, organization_id: organization.id) }
  let(:origin_nexus) { FactoryBot.create(:legacy_nexus, organization: organization) }
  let(:destination_nexus) { FactoryBot.create(:legacy_nexus, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly") }
  let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: "quickly") }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:trips) do
    [
      FactoryBot.create(:trip_with_layovers,
        itinerary: itinerary, load_type: "container", tenant_vehicle: tenant_vehicle),
      FactoryBot.create(:trip_with_layovers,
        itinerary: itinerary, load_type: "container", tenant_vehicle: tenant_vehicle_2)
    ]
  end
  let(:shipment) {
    FactoryBot.create(:legacy_shipment,
      with_breakdown: true, with_tenders: true, organization: organization, user: user)
  }
  let(:quotation) do
    FactoryBot.create(:quotations_quotation, user: user, legacy_shipment_id: shipment.id, tenders:
      FactoryBot.create_list(:quotations_tender, 5))
  end

  let(:quotation_2) { FactoryBot.create(:quotations_quotation, legacy_shipment_id: shipment.id, user: user) }

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:organizations_scope, target: organization, content: {base_pricing: true})
    [tenant_vehicle, tenant_vehicle_2].each do |t_vehicle|
      FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, tenant_vehicle: t_vehicle, organization: organization)
    end
    OfferCalculator::Schedule.from_trips(trips)
    FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle, organization: organization)
    FactoryBot.create(:freight_margin,
      default_for: "ocean", organization: organization, applicable: organization, value: 0)
    shipment.charge_breakdowns.update(tender_id: quotation.tenders.first.id)

    FactoryBot.create(:legacy_charge_breakdown, with_tender: true, quotation: quotation_2)
  end

  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
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
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: {type: :string},
                       type: {type: :string},
                       attributes: {
                         type: :object,
                         properties: {
                           carrier: {
                             type: :string,
                             nullable: true
                           },
                           destination: {type: :string},
                           estimated: {type: :boolean},
                           id: {type: :string},
                           modeOfTransport: {type: :string},
                           origin: {type: :string},
                           quotationId: {type: :string},
                           serviceLevel: {type: :string},
                           total: {"$ref" => "#/components/schemas/money"},
                           transitTime: {type: :number},
                           transshipment: {type: :string},
                           exchangeRates: {
                             type: :object,
                             properties: {
                               base: {type: :string}
                             }
                           }
                         },
                         required: %w[carrier destination estimated id
                           modeOfTransport origin quotationId serviceLevel
                           total transitTime transshipment]
                       }
                     }
                   }
                 }
               },
               required: ["data"]

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
        let(:id) { quotation_2.id }

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
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          tenders: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: {type: :string}
              }
            }
          }
        }
      }

      before do
        FactoryBot.create(:organizations_theme, organization: organization)
      end

      response "200", "successful operation" do
        let(:organization_id) { organization.id }
        let(:id) { quotation.id }
        let(:params) { {tenders: [{id: quotation.tenders.first.id}]} }

        run_test!
      end
    end
  end
end
