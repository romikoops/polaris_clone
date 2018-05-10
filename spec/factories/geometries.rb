serialized_coordinate_pairs = "
	11.110000,57.000000 11.100000,57.000000 11.000000,57.100000 11.100000,57.100000
"

serialized_coordinate_pairs = serialized_coordinate_pairs.split
points = serialized_coordinate_pairs.map do |serialized_coordinate_pair|
	RGeo::Cartesian.factory.point(*serialized_coordinate_pair.split(","))
end
multi_point = RGeo::Cartesian.factory.multi_point(points)

FactoryBot.define do
  factory :geometry do
  	data multi_point
		name_1 "Sweden"    
		name_2 "Gothenburg"    
		name_3 "test"    
		name_4 "test"    
  end
end
