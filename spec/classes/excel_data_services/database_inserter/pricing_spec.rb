# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DatabaseInserter::Pricing do
  let(:tenant) { create(:tenant) }
  let!(:hubs) do
    [create(:hub, tenant: tenant, name: 'Gothenburg Port', hub_type: 'ocean'),
     create(:hub, tenant: tenant, name: 'Shanghai Port', hub_type: 'ocean')]
  end
  let(:options) { { tenant: tenant, data: input_data, klass_identifier: klass_identifier, options: {} } }

  describe '.insert' do
    let(:klass_identifier) { 'Pricing' }
    let(:input_data) { build(:excel_data_restructured_correct_pricings) }
    let(:output_data) do
      { itineraries: { number_created: 1, number_updated: 0 },
        pricing_details: { number_created: 1, number_updated: 0 },
        pricings: { number_created: 1, number_updated: 0 },
        stops: { number_created: 2, number_updated: 0 } }
    end

    it 'returns correct stats and creates correct data' do
      stats = described_class.insert(options)
      itinerary = Itinerary.first
      pricing = Pricing.first
      expect(stats).to eq(output_data)
      expect(itinerary.slice(:name, :mode_of_transport).values).to eq(['Gothenburg - Shanghai', 'ocean'])
      expect(pricing.slice(:wm_rate, :effective_date, :expiration_date, :uuid).values).to eq(
        [1000.0,
         Date.parse('Thu, 15 Mar 2018'),
         Date.parse('Sun, 17 Mar 2019'),
         '575cc33f-41f6-45bb-9a71-46dbc777f146']
      )
      expect(Stop.pluck(:itinerary_id).uniq.first).to eq(itinerary.id)
      expect(PricingDetail.first.slice(:rate,
                                       :rate_basis,
                                       :min,
                                       :shipping_type,
                                       :range,
                                       :currency_name,
                                       :priceable_type,
                                       :priceable_id).values)
        .to eq([17, 'PER_WM', 17, 'BAS', [], 'USD', 'Pricing', pricing.id])
    end
  end
end
