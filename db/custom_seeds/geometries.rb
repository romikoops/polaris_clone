
puts "Reading from kml..."
geometry_hash = Hash.from_xml(File.open('db/dummydata/china.kml'))
geometries = geometry_hash['kml']['Document']['Folder']['Placemark']

puts "Seeding Geometries..."
total = geometries.size
completion_percentage = 0
new_completion_percentage = 0
puts
puts "PROGRESS BAR"
puts "_" * 100

geometries.each_with_index do |geo, i|
	# puts '-' * 50
  names = geo['ExtendedData']['SchemaData']['SimpleData']
	# puts names.join(' | ')

  polygons_raw_data = [geo['MultiGeometry']['Polygon']].flatten
    
  polygons = polygons_raw_data.map do |polygon_raw_data|
    serialized_coordinate_pairs = polygon_raw_data['outerBoundaryIs']['LinearRing']['coordinates'].split

    points = serialized_coordinate_pairs.map do |serialized_coordinate_pair|
      RGeo::Cartesian.factory.point(*serialized_coordinate_pair.split(",").map(&:to_f))
    end
    line_string = RGeo::Cartesian.factory.line_string(points)
    
    RGeo::Cartesian.factory.polygon(line_string)
  end
  multi_polygon = RGeo::Cartesian.factory.multi_polygon(polygons)

  name_attributes = names.map.with_index { |name, i| ["name_#{i + 1}", name] }.to_h

  geometry = Geometry.find_or_initialize_by(name_attributes)
  geometry.assign_attributes(data: multi_polygon)

  puts geometry.errors.full_messages unless geometry.save

  new_completion_percentage = i * 100 / total
  if new_completion_percentage > completion_percentage
    completion_percentage = new_completion_percentage
    print "-"
  end
end