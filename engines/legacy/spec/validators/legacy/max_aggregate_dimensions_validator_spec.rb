# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Legacy::MaxAggregateDimensionsValidator do

  let(:args) do
    {
      trip_id: trip.id,
      itinerary_id: itinerary.id,
      tenant: tenant,
      user: user
    }
  end

  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:tenant_vehicle) { FactoryBot.build(:legacy_tenant_vehicle, tenant: tenant) }
  let(:trip) { FactoryBot.build(:legacy_trip, tenant_vehicle: tenant_vehicle) }
  let(:valid_cargos) { [FactoryBot.build(:legacy_cargo_item, quantity: 10)] }
  let(:agg_cargo) { FactoryBot.build(:legacy_aggregated_cargo) }
  let(:invalid_cargos) { [FactoryBot.build(:legacy_cargo_item, quantity: 10_000)] }

  it 'passes validation' do
    expect(Legacy::Shipment.new(args.merge(cargo_items: valid_cargos))).to be_valid
  end

  it 'passes validation with agg cargo' do
    expect(Legacy::Shipment.new(args.merge(aggregated_cargo: agg_cargo))).to be_valid
  end

  it 'fails validation with an above 21770kg' do
    expect(Legacy::Shipment.new(args.merge(cargo_items: invalid_cargos))).to be_invalid
  end
end
