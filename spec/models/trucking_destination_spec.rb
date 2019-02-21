# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TruckingDestination, type: :model do
  context 'class methods' do
    describe '.find_via_distance_to_hub' do
      let(:tenant) { create(:tenant) }
      let(:hub) { create(:hub, :with_lat_lng, tenant: tenant) }
      let!(:trucking_destination) { create(:trucking_destination, :distance) }

      let(:latitude)  { '57.000000' }
      let(:longitude) { '11.100000' }

      context 'basic tests' do
        it 'raises an ArgumentError if no hub is provided' do
          expect {
            described_class.find_via_distance_to_hub(
              latitude: latitude, longitude: longitude
            )
          }.to raise_error(ArgumentError)
        end

        it 'raises an ArgumentError if no latitude is provided' do
          expect {
            described_class.find_via_distance_to_hub(
              hub: hub, longitude: longitude
            )
          }.to raise_error(ArgumentError)
        end

        it 'raises an ArgumentError if no longitude is provided' do
          expect {
            described_class.find_via_distance_to_hub(
              hub: hub, latitude: latitude
            )
          }.to raise_error(ArgumentError)
        end
      end

      context 'main tests' do
        it 'finds correct trucking destination', pending: 'Outdated spec' do
          found_trucking_destination = described_class.find_via_distance_to_hub(
            hub: hub, latitude: latitude, longitude: longitude
          ).first

          expect(found_trucking_destination).to eq(trucking_destination)
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: trucking_destinations
#
#  id           :bigint(8)        not null, primary key
#  zipcode      :string
#  country_code :string
#  city_name    :string
#  distance     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  location_id  :integer
#
