# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Quotations" do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, tokens: {}, with_profile: true) }
  let(:tenants_user) { Tenants::User.find_by(legacy: user) }
  let(:origin_nexus) { FactoryBot.create(:legacy_nexus, tenant: tenant) }
  let(:destination_nexus) { FactoryBot.create(:legacy_nexus, tenant: tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: "Gothenburg Port") }
  let(:destination_hub) { itinerary.hubs.find_by(name: "Shanghai Port") }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly") }
  let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: "quickly") }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
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
      with_breakdown: true, with_tenders: true, tenant: tenant, user: user)
  }
  let(:quotation) do
    FactoryBot.create(:quotations_quotation, tenants_user: tenants_user, tenders:
      FactoryBot.create_list(:quotations_tender, 5))
  end

  before do
    FactoryBot.create(:tenants_scope, target: tenants_tenant, content: {base_pricing: true})
    [tenant_vehicle, tenant_vehicle_2].each do |t_vehicle|
      FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, tenant_vehicle: t_vehicle, tenant: tenant)
    end
    OfferCalculator::Schedule.from_trips(trips)
    FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle, tenant: tenant)
    FactoryBot.create(:freight_margin,
      default_for: "ocean", tenant: tenants_tenant, applicable: tenants_tenant, value: 0)
    shipment.charge_breakdowns.update(tender_id: quotation.tenders.first.id)
  end

  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v1/quotations" do
    post "Create new quotation" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :quote, in: :body, schema: {
        type: :object,
        properties: {
          tenant_id: {type: :string},
          quote: {
            type: :object,
            properties: {
              selected_date: {type: :date},
              tenant_id: {type: :string},
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

      let(:tenant_id) { tenant.id }

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
                           transshipment: {type: :string}
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
            tenant_id: tenants_tenant.id,
            quote: {
              selected_date: Time.zone.now,
              user_id: tenants_user.id,
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

  path "/v1/quotations/{id}" do
    get "Fetch existing quotation" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :id, in: :path, type: :string, schema: {type: :string}
      parameter name: :tenant_id, in: :query, type: :string, schema: {type: :string}

      response "200", "successful operation" do
        let(:tenant_id) { tenants_tenant.id }
        let(:id) { quotation.id }

        run_test!
      end
    end
  end

  path "/v1/quotations/{id}/download" do
    post "Download quotation as PDF" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :id, in: :path, type: :string, schema: {type: :string}
      parameter name: :tenant_id, in: :query, type: :string, schema: {type: :string}
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
        FactoryBot.create(:tenants_theme, tenant: tenants_tenant)
      end

      response "200", "successful operation" do
        let(:tenant_id) { tenants_tenant.id }
        let(:id) { quotation.id }
        let(:params) { {tenders: [{id: quotation.tenders.first.id}]} }

        run_test!
      end
    end
  end
end
