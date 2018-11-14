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
  RGeo::Cartesian.factory.point(*serialized_coordinate_pair.split(",").map(&:to_f))
end
line_string   = RGeo::Cartesian.factory.line_string(points)
polygon       = RGeo::Cartesian.factory.polygon(line_string)
multi_polygon = RGeo::Cartesian.factory.multi_polygon([polygon])

FactoryBot.define do
  factory :location do
    neighbourhood 'Vastra Volunda'
    suburb ''
    postal_code '43813'
    city 'Gothenburg'
    province ''
    admin_level '1'
    country 'Sweden'
    bounds multi_polygon
  end
end
