geometry_hash = Hash.from_xml(File.open('db/dummydata/china.kml'))
geometries = geometry_hash['kml']['Document']['Folder']['Placemark']

geometries.each do |geo|
	puts '-' * 50
  names = geo['ExtendedData']['SchemaData']['SimpleData']
	puts names.join(' | ')
  
  polygons = [geo['MultiGeometry']['Polygon']].flatten

	polygons_raw_coordinates_str = polygons.map do |polygon|
		polygon['outerBoundaryIs']['LinearRing']['coordinates']
	end

  raw_points_str = polygons_raw_coordinates_str.join(" ")

  raw_points = raw_points_str.split

  points = raw_points.map { |raw_point| RGeo::Cartesian.factory.point(*raw_point.split(",")) }
  multi_point = RGeo::Cartesian.factory.multi_point(points)

  geometry = Geometry.new(data: multi_point)

  names.each_with_index { |name, i| geometry["name_#{i + 1}"] = name }

  puts geometry.errors.full_messages unless geometry.save
end