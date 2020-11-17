# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Country, type: :model do
    before(:all) do
      Geocoder.configure(lookup: :test)
      Geocoder::Lookup::Test.reset
      Geocoder::Lookup::Test.add_stub(
        { country: 'asdfas' }, []
      )
      Geocoder::Lookup::Test.add_stub(
        { country: 'sweden' }, [
          {
            'address_components' => [{ 'long_name' => 'Sweden', 'short_name' => 'SE', 'types' => %w[country political] }],
            'formatted_address' => 'Sweden',
            'geometry' =>
            { 'bounds' => {
              'northeast' => { 'lat' => 69.0599709, 'lng' => 24.1773101 },
              'southwest' => { 'lat' => 55.0059799, 'lng' => 10.5798 }
            },
              'location' => {
                'lat' => 60.12816100000001, 'lng' => 18.643501
              },
              'location_type' => 'APPROXIMATE',
              'viewport' => {
                'northeast' => { 'lat' => 69.0599709, 'lng' => 24.1773101 },
                'southwest' => { 'lat' => 55.0059799, 'lng' => 10.5798 }
              } },
            'partial_match' => true,
            'place_id' => 'ChIJ8fA1bTmyXEYRYm-tjaLruCI',
            'types' => %w[country political]
          }
        ]
      )
    end

    describe '.geo_find_by_name' do
      it 'returns nil if no country was found' do
        expect(Country.geo_find_by_name('asdfas')).to be_nil
      end

      it 'returns the correct country' do
        country = FactoryBot.create(:legacy_country)
        expect(Country.geo_find_by_name('sweden')).to eq(country)
      end
    end

    describe '.geo_find_by_names' do
      it 'returns nil if no countries was found' do
        expect(Country.geo_find_by_name('asdfas')).to be_nil
      end

      it 'returns the correct countries' do
        country = FactoryBot.create(:legacy_country, name: 'sweden')
        target = Country.geo_find_by_names('sweden')
        expect(target.first.name).to eq('Sweden')
      end
    end
  end
end

# == Schema Information
#
# Table name: countries
#
#  id         :bigint           not null, primary key
#  name       :string
#  code       :string
#  flag       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
