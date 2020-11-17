# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::RouteFinder do
  before do
    ::Organizations.current_id = organization.id

    FactoryBot.create(:legacy_max_dimensions_bundle, organization: organization)
    FactoryBot.create(:aggregated_max_dimensions_bundle, organization: organization)

    FactoryBot.create(:organizations_scope, target: organization, content: { base_pricing: true })

    FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle: tenant_vehicle)
    FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle: tenant_vehicle, load_type: 'container')
    FactoryBot.create(:lcl_pricing, itinerary: itinerary, organization: organization, tenant_vehicle: tenant_vehicle)
    FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, organization: organization, tenant_vehicle: tenant_vehicle)
    FactoryBot.create(:fcl_40_pricing, itinerary: itinerary, organization: organization, tenant_vehicle: tenant_vehicle)
    FactoryBot.create(:fcl_40_hq_pricing, itinerary: itinerary, organization: organization, tenant_vehicle: tenant_vehicle)
  end

  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: 'cargo_item',
                      user: user,
                      organization: organization)
  end
  let(:quotation) { FactoryBot.create(:quotations_quotation, legacy_shipment_id: shipment.id) }
  let(:hubs) do
    {
      origin: Legacy::Hub.where(id: origin_hub.id),
      destination: Legacy::Hub.where(id: destination_hub.id)
    }
  end
  let(:date_range) { (Time.zone.today..Time.zone.today + 20.days) }
  let(:results) {
    described_class.routes(shipment: shipment, quotation: quotation, hubs: hubs, date_range: date_range)
  }

  describe '.perform', :vcr do
    context 'with success' do
      it 'return the route detail hashes' do
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.first.origin_stop_id).to eq(itinerary.stops.first.id)
          expect(results.first.destination_stop_id).to eq(itinerary.stops.last.id)
        end
      end
    end

    context 'with failure' do
      before do
        allow(OfferCalculator::Route).to receive(:attributes_from_hub_and_itinerary_ids).and_return(nil)
      end

      it 'raises NoRoute when no routes match the query' do
        expect { results }.to raise_error(OfferCalculator::Errors::NoRoute)
      end
    end
  end
end
