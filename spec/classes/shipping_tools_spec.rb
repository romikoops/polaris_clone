# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShippingTools do
  let(:trip) { create(:trip) }
  let(:user) { build(:user) }
  let(:shipment) { create(:shipment, user: user, trip: trip) }
  let(:params) {
    { shipment_id: shipment.id, meta: { tender_id: '123abc' },
      schedule: { 'trip_id' => trip.id, charge_trip_id: trip.id,
                  'origin_hub': { id: Hub.first.id }, 'destination_hub': { id: Hub.last.id } } }
  }

  describe '.choose_offer' do
    it 'assigns the id of the chosen tender to the meta data of the shipment' do
      create(:charge_breakdown, shipment: shipment)

      expect { ShippingTools.choose_offer(params, user) }.to change { Shipment.find(shipment.id).meta }.from({}).to('pricing_rate_data' => nil, 'tender_id' => '123abc')
    end
  end

  describe '.request_shipment' do
    it 'persists data into the engine models' do
      cargo_creator = double('Cargo::Creator', errors: [])
      shipment_request_creator = double('Shipments::ShipmentRequestCreator', errors: [])
      shipment_request = double('Shipments::ShipmentRequest', id: 1, tenant_id: 123)

      expect(Cargo::Creator).to receive(:new).with(legacy_shipment: shipment).and_return(cargo_creator)
      expect(cargo_creator).to receive(:perform).exactly(1).times

      expect(Shipments::ShipmentRequestCreator).to receive(:new).with(legacy_shipment: shipment, user: user, sandbox: nil).and_return(shipment_request_creator)
      expect(shipment_request_creator).to receive(:create).exactly(1).times
      expect(shipment_request_creator).to receive(:shipment_request).and_return(shipment_request)

      expect(Integrations::Processor).to receive(:process).exactly(1).times.with(shipment_request_id: 1, tenant_id: 123)

      ShippingTools.request_shipment(params, user)
    end
  end
end
