# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::QuotationTenderSerializer do
    let!(:organization) { FactoryBot.create(:organizations_organization) }

    let(:charge_category) { FactoryBot.create(:bas_charge) }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary) }
    let(:trip) { FactoryBot.create(:legacy_trip, vessel: 'Cap San Diego', itinerary: itinerary) }
    let(:shipment) { FactoryBot.create(:legacy_shipment, with_full_breakdown: true, with_tenders: true, trip: trip, organization_id: organization.id) }
    let(:tender) { shipment.charge_breakdowns.first.tender }
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
      expect(target[:charges].count).to eq(24)
    end
  end
end
