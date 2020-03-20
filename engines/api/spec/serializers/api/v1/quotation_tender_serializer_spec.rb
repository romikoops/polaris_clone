# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::QuotationTenderSerializer do
    let(:tenant) { FactoryBot.create(:legacy_tenant) }

    let(:charge_category) { FactoryBot.create(:bas_charge) }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary) }
    let(:trip) { FactoryBot.create(:legacy_trip, vessel: 'Cap San Diego', itinerary: itinerary) }
    let(:charge_breakdown) { FactoryBot.create(:legacy_charge_breakdown, trip: trip) }
    let(:tender) { FactoryBot.create(:quotations_tender, charge_breakdown: charge_breakdown) }
    let(:decorated_tender) { Api::V1::TenderDecorator.new(tender, context: { scope: {} }) }
    let(:serialized_tender) { described_class.new(decorated_tender, params: { scope: {} }).serializable_hash }
    let(:target) { serialized_tender.dig(:data, :attributes) }

    before do
      FactoryBot.create(:quotations_line_item, charge_category: charge_category, tender: tender)
    end

    it 'returns the correct route for the object passed' do
      expect(target[:route]).to eq('Gothenburg - Shanghai')
    end

    it 'returns the correct vessel for the object passed' do
      expect(target[:vessel]).to eq('Cap San Diego')
    end

    it 'returns the correct transit_time for the object passed' do
      expect(target[:transitTime]).to eq((trip.end_date.to_date - trip.start_date.to_date).to_i)
    end

    it 'returns the correct charges for the object passed' do
      expect(target[:charges].count).to eq(tender.line_items.count)
    end
  end
end
