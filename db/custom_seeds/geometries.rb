geometry_hash = Hash.from_xml(File.open('db/dummydata/china.kml'))
geometries = geometry_hash['kml']['Document']['Folder']['Placemark']

geometries.each do |geo|
	puts '-' * 50
  names = geo['ExtendedData']['SchemaData']['SimpleData']
	puts names.join(' | ')
  polygons_raw_data = [geo['MultiGeometry']['Polygon']].flatten
  polygons_serialized_coordinate_pairs = polygons_raw_data.map do |polygon_raw_data|
    polygon_raw_data['outerBoundaryIs']['LinearRing']['coordinates']
  end

  serialized_coordinate_pairs = polygons_serialized_coordinate_pairs.join(" ")
  coordinate_pairs = serialized_coordinate_pairs.split
  points = coordinate_pairs.map do |serialized_coordinate_pair|
    RGeo::Cartesian.factory.point(*serialized_coordinate_pair.split(","))
  end
  line_string = RGeo::Cartesian.factory.line_string(points)
  polygon     = RGeo::Cartesian.factory.polygon(line_string)


  name_attributes = names.map.with_index { |name, i| ["name_#{i + 1}", name] }.to_h

  geometry = Geometry.find_or_initialize_by(name_attributes)
  geometry.assign_attributes(data: polygon)

  puts geometry.errors.full_messages unless geometry.save
end