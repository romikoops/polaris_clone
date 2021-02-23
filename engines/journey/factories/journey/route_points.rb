# frozen_string_literal: true
FactoryBot.define do
  factory :journey_route_point, class: "Journey::RoutePoint" do
    transient do
      latitude { 57.694253 }
      longitude { 11.854048 }
    end

    coordinates { RGeo::Geos.factory(srid: 4326).point(longitude, latitude) }
    function { "ocean" }
    name { "Hamburg" }
    locode { "DEHAM" }
    sequence(:geo_id) { |x| "GEOID-#{x}" }
  end
end
