# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Hub, type: :model do
    describe '.lat_lng_string' do
      let(:hub) { FactoryBot.build(:legacy_hub, :with_lat_lng) }

      it 'returns a string' do
        expect(hub.lat_lng_string).to eql('57.694253,11.854048')
      end
    end

    describe '.distance_to' do
      let(:hub) { FactoryBot.build(:legacy_hub, :with_lat_lng) }
      let(:loc) { FactoryBot.build(:legacy_hub, :with_lat_lng) }

      it 'returns a string' do
        expect(hub.distance_to(loc)).to eql(0.0)
      end
    end

    describe '.lng_lat_array' do
      let(:hub) { FactoryBot.build(:legacy_hub, :with_lat_lng) }

      it 'returns a string' do
        expect(hub.lng_lat_array).to eql([11.854048, 57.694253])
      end
    end
  end
end
