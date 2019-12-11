# frozen_string_literal: true

require 'rails_helper'
require 'active_storage'

RSpec.describe ShippingTools do
  before do
    stub_request(:get, 'https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200, body: '', headers: {})
  end
  let(:tenant) { create(:tenant) }
  let!(:itinerary) { create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:trip) { create(:trip, itinerary_id: itinerary.id) }
  let(:origin_hub) { Hub.find_by(name: 'Gothenburg Port')}
  let(:destination_hub) { Hub.find_by(name: 'Shanghai Port')}
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { build(:user, tenant: tenant) }
  let(:shipment) do
    create(:shipment,
      user: user,
      trip: trip,
      tenant: tenant,
      origin_hub: origin_hub,
      destination_hub: destination_hub,
      origin_nexus: origin_hub.nexus,
      destination_nexus: destination_hub.nexus,
    )
  end
  let(:schedules) { [Legacy::Schedule.from_trip(trip)] }
  let(:params) do
    {
      shipment_id: shipment.id,
      meta: { tender_id: '123abc' },
      schedule: {
        'trip_id' => trip.id, charge_trip_id: trip.id,
        'origin_hub': origin_hub,
        'destination_hub': destination_hub
      }
    }.with_indifferent_access
  end

  describe '.choose_offer' do
    it 'assigns the id of the chosen tender to the meta data of the shipment' do
      create(:charge_breakdown, shipment: shipment)

      expect { ShippingTools.choose_offer(params, user) }.to change { Shipment.find(shipment.id).meta }.from({}).to('pricing_rate_data' => nil, 'tender_id' => '123abc')
    end
  end

  context 'sending admin emails on quote download/send' do
    let!(:quotation) { create(:quotation, original_shipment_id: shipment.id) }
    let!(:charge_breakdown) { create(:charge_breakdown, shipment: shipment, trip: trip) }
    let(:results) do
      [
        {
          quote: charge_breakdown.to_nested_hash,
          schedules: [
            {
              'trip_id' => trip.id, charge_trip_id: trip.id,
              'origin_hub': origin_hub,
              'destination_hub': destination_hub
            }
          ],
          meta: {trip_id: trip.id}
        }.with_indifferent_access
      ]
    end
    let!(:scope) { create(:tenants_scope, target: tenants_tenant, content: {send_email_on_quote_download: true, send_email_on_quote_email: true}) }

    describe '.save_pdf_quotes' do
      it 'successfully calls the mailer and return the quote Document' do
        quote_mailer = double('QuoteMailer')
        allow(quote_mailer).to receive(:deliver_later).and_return(true)
        expect(ShippingTools).to receive(:handle_existing_quote).exactly(1).times.and_return(quotation)
        expect(QuoteMailer).to receive(:quotation_admin_email).exactly(1).times.and_return(quote_mailer)
        expect(quote_mailer).to receive(:deliver_later).exactly(1).times
        result = described_class.save_pdf_quotes(shipment, user.tenant, results)
      end
    end

    describe '.save_and_send_quotes' do
      it 'successfully calls the mailer and return the quote Document' do
        quote_mailer = double('QuoteMailer')
        allow(quote_mailer).to receive(:deliver_later).and_return(true)
        expect(ShippingTools).to receive(:handle_existing_quote).exactly(1).times.and_return(quotation)
        expect(QuoteMailer).to receive(:quotation_admin_email).exactly(1).times.and_return(quote_mailer)
        expect(quote_mailer).to receive(:deliver_later).exactly(1).times
        result = described_class.save_and_send_quotes(shipment, results, user.email)
      end
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
