# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Routing::RoutingService, type: :service do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }
  let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
  let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: legacy_tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:origin_nexus) { origin_hub.nexus }
  let(:destination_nexus) { destination_hub.nexus }
  let(:default_args) { { tenant: tenant, load_type: 'cargo_item' } }

  before do
    FactoryBot.create(:felixstowe_shanghai_itinerary, tenant: legacy_tenant)
    FactoryBot.create(:hamburg_shanghai_itinerary, tenant: legacy_tenant)
  end

  describe '.nexuses' do
    context 'when targeting the origin with query ' do
      let(:args) { default_args.merge(target: :origin_destination, query: 'Goth') }
      let!(:result) { described_class.nexuses(args) }

      it 'Renders a json of origins when query matches origin' do
        expect(result.first.name).to eq(origin_nexus.name)
      end
    end

    context 'when targeting the origin with no params ' do
      let(:args) { default_args.merge(target: :origin_destination) }
      let!(:result) { described_class.nexuses(args) }
      let(:origins) { legacy_tenant.itineraries.map { |itin| itin.first_nexus.name }.sort }

      it 'Renders an array of all origins when location params are empty' do
        expect(result.map(&:name)).to eq(origins)
      end
    end

    context 'when targeting the origin with search query' do
      let(:args) { default_args.merge(query: 'Shan', target: :destination_origin) }
      let!(:result) { described_class.nexuses(args) }

      it 'Renders a json of destinations when query matches destination name' do
        expect(result.first.name).to eq(destination_nexus.name)
      end
    end

    context 'when targeting the origin with no params' do
      let(:args) { default_args.merge(target: :destination_origin) }
      let!(:result) { described_class.nexuses(args) }

      it 'Renders an array of all destinations when location params are empty' do
        expect(result.first.name).to eq(destination_nexus.name)
      end
    end
  end
end
