# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Itinerary, type: :model do
    describe '.parse_load_type' do
      it 'returns the cargo_item for lcl' do
        itinerary = FactoryBot.create(:default_itinerary)
        expect(itinerary.parse_load_type('lcl')).to eq('cargo_item')
      end

      it 'returns the container for fcl' do
        itinerary = FactoryBot.create(:default_itinerary)
        expect(itinerary.parse_load_type('fcl')).to eq('container')
      end
    end

    context 'when finding hubs' do
      let(:organization) { FactoryBot.create(:organizations_organization) }
      let(:o_hub) { FactoryBot.create(:legacy_hub, organization: organization) }
      let(:d_hub) { FactoryBot.create(:legacy_hub, organization: organization) }
      let(:o_stop) { FactoryBot.build(:legacy_stop, hub: o_hub, index: 0) }
      let(:d_stop) { FactoryBot.build(:legacy_stop, hub: d_hub, index: 1) }
      let(:itinerary) do
        FactoryBot.create(:default_itinerary,
                          organization: organization,
                          stops: [
                            o_stop,
                            d_stop
                          ])
      end

      describe '.destination_hub_ids' do
        it 'returns the hub ids for the destination' do
          expect(itinerary.destination_hub_ids).to eq([d_hub.id])
        end
      end

      describe '.destination_hub' do
        it 'returns the hub ids for the destination' do
          expect(itinerary.destination_hub).to eq(d_hub)
        end
      end

      describe '.origin_hub' do
        it 'returns the hub ids for the destination' do
          expect(itinerary.origin_hub).to eq(o_hub)
        end
      end

      describe '.origin_hub_ids' do
        it 'returns the hub ids for the origin' do
          expect(itinerary.origin_hub_ids).to eq([o_hub.id])
        end
      end

      describe '.destination_stops' do
        it 'returns the stops for the destination' do
          expect(itinerary.destination_stops).to eq([d_stop])
        end
      end

      describe '.origin_stops' do
        it 'returns the stops for the destination' do
          expect(itinerary.origin_stops).to eq([o_stop])
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: itineraries
#
#  id                :bigint           not null, primary key
#  mode_of_transport :string
#  name              :string
#  transshipment     :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  organization_id   :uuid
#  sandbox_id        :uuid
#  tenant_id         :integer
#
# Indexes
#
#  index_itineraries_on_mode_of_transport  (mode_of_transport)
#  index_itineraries_on_name               (name)
#  index_itineraries_on_organization_id    (organization_id)
#  index_itineraries_on_sandbox_id         (sandbox_id)
#  index_itineraries_on_tenant_id          (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
