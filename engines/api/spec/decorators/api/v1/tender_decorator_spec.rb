# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::TenderDecorator do
  let(:charge_category) { FactoryBot.create(:bas_charge) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary) }
  let(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary) }
  let(:charge_breakdown) { FactoryBot.create(:legacy_charge_breakdown, trip: trip) }
  let(:tender) { FactoryBot.create(:quotations_tender, charge_breakdown: charge_breakdown) }
  let(:line_item) { FactoryBot.create(:quotations_line_item, charge_category: charge_category) }
  let(:scope) { { fee_detail: 'key_and_name' }.with_indifferent_access }

  describe '.decorate' do
    let(:decorated_tender) { described_class.new(tender, context: { scope: scope }) }

    it 'decorates the tneder with route, vessel and transit times' do
      aggregate_failures do
        expect(decorated_tender.route).to eq(itinerary.name)
        expect(decorated_tender.transit_time).to eq((trip.end_date.to_date - trip.start_date.to_date).to_i)
        expect(decorated_tender.vessel).to eq(trip.vessel)
        expect(decorated_tender.charges.length).to eq(tender.line_items.count)
      end
    end
  end
end
