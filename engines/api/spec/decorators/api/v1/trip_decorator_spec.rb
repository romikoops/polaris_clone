# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::TripDecorator do
  let(:carrier) { FactoryBot.create(:legacy_carrier, name: 'msc') }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'standard', carrier: carrier) }
  let(:trip) { FactoryBot.create(:legacy_trip, tenant_vehicle: tenant_vehicle) }

  describe '.decorate' do
    let(:decorated_trip) { described_class.new(trip) }

    it 'returns the carrier name' do
      expect(decorated_trip.carrier).to eq(carrier.name)
    end

    it 'returns the service' do
      expect(decorated_trip.service).to eq(tenant_vehicle.name)
    end

    it 'returns the start date' do
      expect(decorated_trip.start).to eq(trip.start_date.strftime('%F'))
    end

    it 'returns the end date' do
      expect(decorated_trip.end).to eq(trip.end_date.strftime('%F'))
    end

    it 'returns the closing date' do
      expect(decorated_trip.closing).to eq(trip.closing_date.strftime('%F'))
    end
  end
end
