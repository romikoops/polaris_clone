# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe ItinerarySerializer do
    let(:tenant) { FactoryBot.create(:legacy_tenant) }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
    let(:serialized_itinerary) { described_class.new(itinerary).serializable_hash }

    it 'returns the correct name for the object passed' do
      expect(serialized_itinerary[:name]).to eq('Gothenburg - Shanghai')
    end

    it 'returns the correct mode_of_transport for the object passed' do
      expect(serialized_itinerary[:mode_of_transport]).to eq('ocean')
    end

    it 'returns the correct stops for the object passed' do
      origin_stop = serialized_itinerary[:stops].first
      destination_stop = serialized_itinerary[:stops].last
      expect(serialized_itinerary[:stops].length).to eq(2)
      expect(origin_stop['hub']['name']).to eq('Gothenburg Port')
      expect(destination_stop['hub']['name']).to eq('Shanghai Port')
    end
  end
end
