# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_bounds, class: "RGeo::Geos::CAPIMultiPolygonImpl" do
    lat { 53.558572 }
    lng { 9.9278215 }
    delta { 0.4 }
    initialize_with do
      serialized_coordinate_pairs = [
        "#{lng + delta},#{lat + delta}",
        "#{lng + delta},#{lat - delta}",
        "#{lng - delta},#{lat - delta}",
        "#{lng - delta},#{lat + delta}",
        "#{lng + delta},#{lat + delta}"
      ]

      points = serialized_coordinate_pairs.map { |serialized_coordinate_pair|
        RGeo::Cartesian.factory.point(*serialized_coordinate_pair.split(",").map(&:to_f))
      }
      line_string = RGeo::Cartesian.factory(srid: 4326).line_string(points)
      polygon = RGeo::Cartesian.factory(srid: 4326).polygon(line_string)
      RGeo::Cartesian.factory(srid: 4326).multi_polygon([polygon])
    end
  end
end
