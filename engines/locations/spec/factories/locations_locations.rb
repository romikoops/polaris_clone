# frozen_string_literal: true

lat = 57.000000
lng = 11.100000
delta = 0.3

# Hardcoding a square polygon around the lat, lng  pair to be tested.
serialized_coordinate_pairs = [
  "#{lng + delta},#{lat + delta}",
  "#{lng + delta},#{lat - delta}",
  "#{lng - delta},#{lat - delta}",
  "#{lng - delta},#{lat + delta}",
  "#{lng + delta},#{lat + delta}"
]

points = serialized_coordinate_pairs.map do |serialized_coordinate_pair|
  RGeo::Cartesian.factory.point(*serialized_coordinate_pair.split(',').map(&:to_f))
end
line_string   = RGeo::Cartesian.factory.line_string(points)
polygon       = RGeo::Cartesian.factory.polygon(line_string)
se_multi_polygon = RGeo::Cartesian.factory.multi_polygon([polygon])

delta = 0.5
serialized_coordinate_pairs = [
  "#{lng + delta},#{lat + delta}",
  "#{lng + delta},#{lat - delta}",
  "#{lng - delta},#{lat - delta}",
  "#{lng - delta},#{lat + delta}",
  "#{lng + delta},#{lat + delta}"
]

points = serialized_coordinate_pairs.map do |serialized_coordinate_pair|
  RGeo::Cartesian.factory.point(*serialized_coordinate_pair.split(',').map(&:to_f))
end
line_string   = RGeo::Cartesian.factory.line_string(points)
polygon       = RGeo::Cartesian.factory.polygon(line_string)
se_large_multi_polygon = RGeo::Cartesian.factory.multi_polygon([polygon])

FactoryBot.define do
  factory :locations_location, class: 'Locations::Location' do
    bounds { '010300000001000000050000000831E1E1874F5E40B5B05D90E3493F400831E1E1874F5E40E9E390C3167D3F40D4FDADAE545C5E40E9E390C3167D3F40D4FDADAE545C5E40B5B05D90E3493F400831E1E1874F5E40B5B05D90E3493F40' } # rubocop:disable Metrics/LineLength
    sequence(:osm_id) { |n| n }
    name { 'Shanghai' }
    admin_level { 8 }
    country_code { 'cn' }

    trait :in_china do
      bounds { '010300000001000000050000000831E1E1874F5E40B5B05D90E3493F400831E1E1874F5E40E9E390C3167D3F40D4FDADAE545C5E40E9E390C3167D3F40D4FDADAE545C5E40B5B05D90E3493F400831E1E1874F5E40B5B05D90E3493F40' } # rubocop:disable Metrics/LineLength
      osm_id { '11111' }
      name { 'Shanghai' }
      country_code { 'cn' }
      admin_level { 8 }
    end
    trait :in_sweden do
      bounds { se_multi_polygon }
      osm_id { '22222' }
      name { 'Gothenburg' }
      admin_level { 8 }
      country_code { 'se' }
    end
    trait :postal_sweden do
      bounds { se_multi_polygon }
      osm_id { nil }
      name { '22222' }
      admin_level { 8 }
      country_code { 'se' }
    end
    trait :in_germany do
      bounds { '010300000001000000050000000831E1E1874F5E40B5B05D90E3493F400831E1E1874F5E40E9E390C3167D3F40D4FDADAE545C5E40E9E390C3167D3F40D4FDADAE545C5E40B5B05D90E3493F400831E1E1874F5E40B5B05D90E3493F40' } # rubocop:disable Metrics/LineLength
      osm_id { '22222' }
      name { 'Altenberg Bårenfels' }
      country_code { 'de' }
      admin_level { nil }
    end
    trait :postal_germany do
      bounds { '010300000001000000050000000831E1E1874F5E40B5B05D90E3493F400831E1E1874F5E40E9E390C3167D3F40D4FDADAE545C5E40E9E390C3167D3F40D4FDADAE545C5E40B5B05D90E3493F400831E1E1874F5E40B5B05D90E3493F40' } # rubocop:disable Metrics/LineLength
      osm_id { '1' }
      name { '10001' }
      country_code { 'de' }
      admin_level { nil }
    end

    trait :in_sweden_large do
      bounds { se_large_multi_polygon }
      osm_id { '22222' }
      name { 'Gothenburg' }
      admin_level { 8 }
      country_code { 'se' }
    end

    factory :swedish_location, traits: [:in_sweden]
    factory :xl_swedish_location, traits: [:in_sweden_large]
    factory :chinese_location, traits: [:in_china]
    factory :german_location, traits: [:in_germany]
    factory :german_postal_location, traits: [:postal_germany]
    factory :swedish_postal_location, traits: [:postal_sweden]
  end
end

# == Schema Information
#
# Table name: locations_locations
#
#  id           :uuid             not null, primary key
#  admin_level  :integer
#  bounds       :geometry         geometry, 0
#  country_code :string
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  osm_id       :bigint
#
# Indexes
#
#  index_locations_locations_on_bounds  (bounds) USING gist
#  index_locations_locations_on_name    (name)
#  index_locations_locations_on_osm_id  (osm_id)
#
