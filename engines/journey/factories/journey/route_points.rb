# frozen_string_literal: true

FactoryBot.define do
  factory :journey_route_point, class: "Journey::RoutePoint" do
    transient do
      latitude { 57.694253 }
      longitude { 11.854048 }
    end

    coordinates { RGeo::Geos.factory(srid: 4326).point(longitude, latitude) }
    sequence(:geo_id) { |x| "GEOID-#{x}" }
    locode
    country { "DE" }

    trait :locode do
      function { "ocean" }
      name { "Hamburg" }
      locode { "DEHAM" }
    end

    trait :terminal do
      function { "ocean" }
      name { "Hamburg" }
      locode { "DEHAM" }
      terminal { "1-A" }
    end

    trait :address do
      locode { nil }
      function { "address" }
      name { "Brooktorkai 7" }
    end

    factory :journey_route_point_address, traits: [:address]
  end
end
