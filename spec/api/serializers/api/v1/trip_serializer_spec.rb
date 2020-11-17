# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::TripSerializer do
    let(:carrier) { FactoryBot.create(:legacy_carrier, name: 'msc') }
    let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'standard', carrier: carrier) }
    let(:trip) { FactoryBot.create(:legacy_trip, tenant_vehicle: tenant_vehicle, vessel: 'test', voyage_code: '1234') }
    let(:decorated_trip) { Api::V1::TripDecorator.new(trip) }
    let(:serialized_trip) { described_class.new(decorated_trip).serializable_hash }
    let(:target) { serialized_trip.dig(:data, :attributes) }

    it 'returns the carrier name' do
      expect(target[:carrier]).to eq(carrier.name)
    end

    it 'returns the service' do
      expect(target[:service]).to eq(tenant_vehicle.name)
    end

    it 'returns the start date' do
      expect(target[:start]).to eq(trip.start_date.strftime('%F'))
    end

    it 'returns the end date' do
      expect(target[:end]).to eq(trip.end_date.strftime('%F'))
    end

    it 'returns the closing date' do
      expect(target[:closing]).to eq(trip.closing_date.strftime('%F'))
    end

    it 'returns the vessel' do
      expect(target[:vessel]).to eq(trip.vessel)
    end

    it 'returns the voyage code' do
      expect(target[:voyageCode]).to eq(trip.voyage_code)
    end
  end
end
