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
  factory :geometry do
  	data multi_polygon
		name_1 "Sweden"    
		name_2 "Gothenburg"    
		name_3 "Testname3"    
		name_4 "Testname4"    
  end
end

# == Schema Information
#
# Table name: geometries
#
#  id         :bigint(8)        not null, primary key
#  name_1     :string
#  name_2     :string
#  name_3     :string
#  name_4     :string
#  data       :geometry({:srid= geometry, 0
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
