# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wheelhouse::TenderDecorator do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:itinerary) { FactoryBot.create(:hamburg_shanghai_itinerary, tenant: tenant) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier: FactoryBot.create(:legacy_carrier, name: 'Maersk')) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Hamburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:tender) do
    FactoryBot.create(:quotations_tender,
                      itinerary: itinerary,
                      origin_hub: origin_hub,
                      destination_hub: destination_hub,
                      tenant_vehicle: tenant_vehicle,
                      amount: Money.new(25_000, 'EUR'))
  end
  let!(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle: tenant_vehicle, load_type: 'container') }

  describe '.decorate' do
    let(:decorated_tender) do
      described_class.new(tender)
    end

    it 'decorates the tender with attributes 1/2' do
      aggregate_failures do
        expect(decorated_tender.origin).to eq(origin_hub.name)
        expect(decorated_tender.destination).to eq(destination_hub.name)
        expect(decorated_tender.carrier).to eq('Maersk')
      end
    end

    it 'decorates the tender with attributes 2/2' do
      aggregate_failures do
        expect(decorated_tender.total).to eq('€250.00')
        expect(decorated_tender.transit_time).to eq((trip.end_date.to_date - trip.start_date.to_date).to_i)
        expect(decorated_tender.transshipment).to eq('direct')
        expect(decorated_tender.service_level).to eq(tenant_vehicle.name)
      end
    end

    context 'with transshipment' do
      let(:tender) do
        FactoryBot.create(:quotations_tender,
                          itinerary: itinerary,
                          origin_hub: origin_hub,
                          destination_hub: destination_hub,
                          tenant_vehicle: tenant_vehicle,
                          transshipment: 'ZACPT',
                          amount: Money.new(25_000, 'EUR'))
      end

      it 'returns the transshipment LOCODE' do
        expect(decorated_tender.transshipment).to eq('ZACPT')
      end
    end
  end
end
