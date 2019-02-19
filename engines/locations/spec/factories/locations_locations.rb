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
    trait :in_china do
      bounds { '010300000001000000050000000831E1E1874F5E40B5B05D90E3493F400831E1E1874F5E40E9E390C3167D3F40D4FDADAE545C5E40E9E390C3167D3F40D4FDADAE545C5E40B5B05D90E3493F400831E1E1874F5E40B5B05D90E3493F40' }
      osm_id { '11111' }
      name { 'Shanghai' }
      admin_level { 8 }
    end
    trait :in_sweden do
      bounds { se_multi_polygon }
      osm_id { '22222' }
      name { 'Gothenburg' }
      admin_level { 8 }
    end
    trait :in_germany do
      bounds { '010300000001000000050000000831E1E1874F5E40B5B05D90E3493F400831E1E1874F5E40E9E390C3167D3F40D4FDADAE545C5E40E9E390C3167D3F40D4FDADAE545C5E40B5B05D90E3493F400831E1E1874F5E40B5B05D90E3493F50' }
      osm_id { '22222' }
      name { 'Altenberg Bårenfels' }
      admin_level { nil }
    end
    trait :postal_germany do
      bounds { '010300000001000000050000000831E1E1874F5E40B5B05D90E3493F400831E1E1874F5E40E9E390C3167D3F40D4FDADAE545C5E40E9E390C3167D3F40D4FDADAE545C5E40B5B05D90E3493F400831E1E1874F5E40B5B05D90E3493F40' }
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
    end

    factory :swedish_location, traits: [:in_sweden]
    factory :xl_swedish_location, traits: [:in_sweden]
    factory :chinese_location, traits: [:in_china]
    factory :german_location, traits: [:in_germany]
    factory :german_postal_location, traits: [:postal_germany]
  end
end
