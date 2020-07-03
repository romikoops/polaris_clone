# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Routing::NexusRoutingService, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', organization: organization) }
  let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization_id: organization.id) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:origin_nexus) { origin_hub.nexus }
  let(:destination_nexus) { destination_hub.nexus }
  let(:query) { nil }
  let(:result) do
    described_class.nexuses(
      organization: organization,
      query: query,
      nexus_id: nexus_id,
      load_type: 'cargo_item',
      target: target
    )
  end

  before do
    FactoryBot.create(:felixstowe_shanghai_itinerary, organization_id: organization.id)
    FactoryBot.create(:hamburg_shanghai_itinerary, organization_id: organization.id)
  end

  describe '.nexuses' do
    context 'when targeting the origin with destination id' do
      let(:nexus_id) { destination_hub.nexus_id }
      let(:target) { :origin_destination }
      let(:origins) { Legacy::Itinerary.where(organization_id: organization.id).map { |itin| itin.first_nexus.name }.sort }

      it 'Renders a json of origins for given a destination id' do
        expect(result.pluck(:name)).to eq(origins)
      end
    end

    context 'when targeting the origin with query ' do
      let(:target) { :origin_destination }
      let(:query) { origin_hub.name.first(4) }
      let(:nexus_id) { destination_hub.nexus_id }

      it 'Renders a json of origins when query matches origin' do
        expect(result.first.name).to eq(origin_hub.nexus.name)
      end
    end

    context 'when targeting the origin with destination id and query and multiple hubs' do
      before do
        hub_name = origin_hub.name.split(' ').first + ' Airport'
        FactoryBot.create(:legacy_hub, name: hub_name, hub_type: 'air', nexus: origin_hub.nexus)
      end

      let(:nexus_id) { destination_hub.nexus_id }
      let(:query) { origin_hub.nexus.name.first(5) }
      let(:target) { :origin_destination }

      it 'Renders a json of origins for given a destination lat lng' do
        expect(result.pluck(:name)).to match_array([origin_hub.nexus.name])
      end
    end

    context 'when targeting the destination with origin id ' do
      let(:target) { :destination_origin }
      let(:nexus_id) { origin_hub.nexus_id }

      it 'Renders a json of destinations for a given a origin id' do
        expect(result.first.name).to eq(destination_nexus.name)
      end
    end

    context 'when targeting the destination with search query' do
      let(:target) { :destination_origin }
      let(:query) { destination_hub.name.first(4) }
      let(:nexus_id) { origin_hub.nexus_id }

      it 'Renders a json of destinations when query matches destination name' do
        expect(result.first.name).to eq(destination_hub.nexus.name)
      end
    end
  end
end
