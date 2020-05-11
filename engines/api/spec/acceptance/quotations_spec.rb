# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Quotations', acceptance: true do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header

  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, tokens: {}, with_profile: true) }
  let(:tenants_user) { Tenants::User.find_by(legacy: user) }
  let(:origin_nexus) { FactoryBot.create(:legacy_nexus, tenant: tenant) }
  let(:destination_nexus) { FactoryBot.create(:legacy_nexus, tenant: tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly') }
  let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: 'quickly') }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:trip_1) { FactoryBot.create(:trip_with_layovers, itinerary: itinerary, load_type: 'container', tenant_vehicle: tenant_vehicle) }
  let(:trip_2) { FactoryBot.create(:trip_with_layovers, itinerary: itinerary, load_type: 'container', tenant_vehicle: tenant_vehicle_2) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: tenants_user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }

  before do
    FactoryBot.create(:tenants_theme, tenant: tenants_tenant)
    FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { base_pricing: true })
  end

  post '/v1/quotations' do
    with_options scope: :quote, with_example: true do
      parameter :selected_date, 'The expected date of the shipment', required: true
      parameter :tenant_id, "The tenant's identifier", required: true
      parameter :user_id, "The user's identifier", required: true
      parameter :origin, 'Details of the origin, contains nexus_id or address information', required: true
      parameter :destination, 'Details of the origin, contains nexus_id or address information', required: true
    end

    with_options scope: :shipment_info, with_example: true do
      parameter :cargo_item_attributes, 'An array containing the attributes belonging to each cargo'
      parameter :containers_attributes, 'An array containing the attributes belonging to each container'
      parameter :trucking_info, 'Object containing pre/on carriage keys with truck_type as values (required for trucking)'
    end

    context 'when port to port' do
      let(:trips) { [trip_1, trip_2] }
      let(:request) do
        {
          quote: {
            selected_date: Time.zone.now,
            tenant_id: tenant.id,
            user_id: tenants_user.id,
            load_type: 'container',
            origin: { nexus_id: origin_hub.nexus_id },
            destination: { nexus_id: destination_hub.nexus_id }
          },
          shipment_info: { trucking_info: {} }
        }
      end

      before do
        [tenant_vehicle, tenant_vehicle_2].each do |t_vehicle|
          FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, tenant_vehicle: t_vehicle, tenant: tenant)
        end
        OfferCalculator::Schedule.from_trips(trips)
        FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle, tenant: tenant)
        FactoryBot.create(:freight_margin, default_for: 'ocean', tenant: tenants_tenant, applicable: tenants_tenant, value: 0)
      end

      example 'getting a quotation with port to port parameters' do
        do_request(request)
        aggregate_failures do
          expect(status).to eq(200)
          expect(response_data.dig(0, 'attributes', 'total')).to eq('amount' => 250.00, 'currency' => 'EUR')
        end
      end
    end
  end

  get 'v1/quotations/:quotation_id' do
    context 'when a quotation exists' do
      let(:shipment) { FactoryBot.create(:legacy_shipment, with_breakdown: true, tenant: tenant, user: user) }

      let(:quotation) do
        FactoryBot.create(:quotations_quotation, tenants_user: tenants_user, tenders:
        FactoryBot.create_list(:quotations_tender, 5))
      end
      let(:request) do
        {
          quotation_id: quotation.id
        }
      end

      before do
        shipment.charge_breakdowns.update(tender_id: quotation.tenders.first.id)
      end

      with_options with_example: true do
        parameter :quotation_id, 'The Id of the quotation to show', required: true
      end

      example 'returns a quotation with the given id' do
        do_request(request)

        expect(status).to eq(200)
      end
    end
  end

  post '/v1/quotations/:quotation_id/download' do
    with_options scope: :quote, with_example: true do
      parameter :tenders, 'The selected tenders for download', required: true
      parameter :quotation_id, 'The selected shipment id', required: false
    end

    context 'when downloading a pdf' do
      let(:shipment) { FactoryBot.create(:legacy_shipment, with_breakdown: true, with_tenders: true, tenant: tenant, user: user) }
      let(:request) do
        {
          quotation_id: shipment.id,
          tenders: [
            { id: Quotations::Tender.first.id }
          ]
        }
      end

      example 'getting a quotation pdf with the selected offers on it' do
        do_request(request)
        aggregate_failures do
          expect(status).to eq(200)
          expect(response_data.dig('attributes', 'url')).to include('test.host')
        end
      end
    end
  end
end
