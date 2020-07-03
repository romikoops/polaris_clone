# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wheelhouse::TenderDecorator do
  let(:itinerary) { FactoryBot.create(:default_itinerary) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier: FactoryBot.create(:legacy_carrier, name: 'Maersk')) }
  let(:origin_hub) { itinerary.hubs.first }
  let(:destination_hub) { itinerary.hubs.last }
  let!(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle: tenant_vehicle, load_type: 'container') }
  let(:amount) { Money.new(25_090, 'EUR') }
  let(:transshipment) { nil }
  let(:context) { nil }
  let(:tender) do
    FactoryBot.create(:quotations_tender,
                      itinerary: itinerary,
                      origin_hub: origin_hub,
                      destination_hub: destination_hub,
                      tenant_vehicle: tenant_vehicle,
                      transshipment: transshipment,
                      amount: amount)
  end
  let(:decorated_tender) { described_class.new(tender, context: context) }

  describe '.decorate' do
    it 'decorates the tender with attributes 1/2' do
      aggregate_failures do
        expect(decorated_tender.origin).to eq(origin_hub.name)
        expect(decorated_tender.destination).to eq(destination_hub.name)
        expect(decorated_tender.carrier).to eq('Maersk')
      end
    end

    it 'decorates the tender with attributes 2/2' do
      aggregate_failures do
        expect(decorated_tender.total).to eq(amount: 250.9, currency: 'EUR')
        expect(decorated_tender.transit_time).to eq((trip.end_date.to_date - trip.start_date.to_date).to_i)
        expect(decorated_tender.transshipment).to eq('direct')
        expect(decorated_tender.service_level).to eq(tenant_vehicle.name)
      end
    end

    context 'with transshipment' do
      let(:transshipment) { 'ZACPT' }

      it 'returns the transshipment LOCODE' do
        expect(decorated_tender.transshipment).to eq('ZACPT')
      end
    end

    context 'when estimated' do
      let(:context) { { estimated: true } }

      it 'returns estimated as true' do
        expect(decorated_tender.estimated).to be_truthy
      end
    end
  end

  describe '.decorate with invalid amount on tender' do
    let(:amount) { Money.new(nil, nil) }

    it 'returns nil for a money object' do
      aggregate_failures do
        expect(decorated_tender.total).to eq(nil)
      end
    end
  end
end
