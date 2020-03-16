# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wheelhouse::TenderDecorator do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:itinerary) { FactoryBot.create(:hamburg_shanghai_itinerary, tenant: tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Hamburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:tender_params) do
    params = { meta: { origin_hub: origin_hub,
                       destination_hub: destination_hub,
                       carrier_name: 'Maersk' },
               quote: {
                 total: {
                   value: '250',
                   currency: 'EUR'
                 }
               } }
    JSON.parse(params.to_json, object_class: Wheelhouse::OpenStruct)
  end
  let(:tender) { Wheelhouse::OpenStruct.new(tender_params) }

  describe '.decorate' do
    let(:decorated_tender) do
      described_class.new(tender)
    end

    it 'decorates the tender with origin destination carrier and toal' do
      aggregate_failures do
        expect(decorated_tender.origin).to eq(origin_hub.name)
        expect(decorated_tender.destination).to eq(destination_hub.name)
        expect(decorated_tender.carrier).to eq('Maersk')
        expect(decorated_tender.total).to eq('€250.00')
        expect(decorated_tender.uuid).not_to be_nil
      end
    end
  end
end
