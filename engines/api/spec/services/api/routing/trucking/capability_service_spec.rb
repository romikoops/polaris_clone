# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Routing::Trucking::CapabilityService, type: :service do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }
  let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: legacy_tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:load_type) { 'cargo_item' }
  let(:args) { { tenant: tenant, load_type: load_type } }

  describe '.capability' do
    context 'when origin and destination have no trucking' do
      let!(:data) { described_class.capability(args) }

      it 'returns falsy result for origin and destination' do
        aggregate_failures do
          expect(data[:origin]).to be_falsy
          expect(data[:destination]).to be_falsy
        end
      end
    end

    context 'when trucking is available only on the origin' do
      before do
        FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location)
      end

      let!(:data) { described_class.capability(args) }

      it 'returns truthy for origin, falsy for destination' do
        aggregate_failures do
          expect(data[:origin]).to be_truthy
          expect(data[:destination]).to be_falsy
        end
      end
    end

    context 'when trucking is available only on the destination' do
      before do
        FactoryBot.create(:lcl_on_carriage_availability, hub: destination_hub, query_type: :location)
      end

      let!(:data) { described_class.capability(args) }

      it 'returns falsy for the origin and truthy for the destination' do
        aggregate_failures do
          expect(data[:origin]).to be_falsy
          expect(data[:destination]).to be_truthy
        end
      end
    end

    context 'when trucking is available on both sides' do
      before do
        FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location)
        FactoryBot.create(:lcl_on_carriage_availability, hub: destination_hub, custom_truck_type: 'default2', query_type: :location)
      end

      let!(:data) { described_class.capability(args) }

      it 'returns truthy for origin and destination' do
        aggregate_failures do
          expect(data[:origin]).to be_truthy
          expect(data[:destination]).to be_truthy
        end
      end
    end
  end
end
