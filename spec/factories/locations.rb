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

points = serialized_coordinate_pairs.map { |serialized_coordinate_pair|
  RGeo::Cartesian.factory.point(*serialized_coordinate_pair.split(",").map(&:to_f))
}
line_string = RGeo::Cartesian.factory(srid: 4326).line_string(points)
polygon = RGeo::Cartesian.factory(srid: 4326).polygon(line_string)
multi_polygon = RGeo::Cartesian.factory(srid: 4326).multi_polygon([polygon])

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

points = serialized_coordinate_pairs.map { |serialized_coordinate_pair|
  RGeo::Cartesian.factory(srid: 4326).point(*serialized_coordinate_pair.split(",").map(&:to_f))
}
line_string = RGeo::Cartesian.factory(srid: 4326).line_string(points)
polygon = RGeo::Cartesian.factory(srid: 4326).polygon(line_string)
multi_polygon = RGeo::Cartesian.factory(srid: 4326).multi_polygon([polygon])

FactoryBot.define do
  factory :location do
    neighbourhood { "Vastra Volunda" }
    suburb { "" }
    postal_code { "43813" }
    city { "Gothenburg" }
    province { "" }
    admin_level { "1" }
    country { "Sweden" }
    bounds { multi_polygon }
  end
end

# == Schema Information
#
# Table name: locations
#
#  id            :bigint(8)        not null, primary key
#  postal_code   :string
#  suburb        :string
#  neighbourhood :string
#  city          :string
#  province      :string
#  country       :string
#  admin_level   :string
#  bounds        :geometry({:srid= geometry, 0
#
