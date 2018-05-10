geometry_hash = Hash.from_xml(File.open('db/dummydata/china.kml'))
geometries = geometry_hash['kml']['Document']['Folder']['Placemark']

geometries.each do |geo|
	puts '-' * 50
  names = geo['ExtendedData']['SchemaData']['SimpleData']
	puts names.join(' | ')
  
  polygons = [geo['MultiGeometry']['Polygon']].flatten
	polygons_serialized_coordinate_pairs = polygons.map do |polygon|
		polygon['outerBoundaryIs']['LinearRing']['coordinates']
	end

  serialized_coordinate_pairs = polygons_serialized_coordinate_pairs.join(" ")
  serialized_coordinate_pairs = serialized_coordinate_pairs.split
  points = serialized_coordinate_pairs.map do |serialized_coordinate_pair|
  	RGeo::Cartesian.factory.point(*serialized_coordinate_pair.split(","))
  end
  multi_point = RGeo::Cartesian.factory.multi_point(points)

  geometry = Geometry.new(data: multi_point)

  names.each_with_index { |name, i| geometry["name_#{i + 1}"] = name }

  puts geometry.errors.full_messages unless geometry.save
end