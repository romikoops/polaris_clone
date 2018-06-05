
# frozen_string_literal: true

puts 'Reading from kml...'
geometry_hash = Hash.from_xml(File.open('db/dummydata/china.kml'))
geometries = geometry_hash['kml']['Document']['Folder']['Placemark']

puts
puts 'Preparing Geometries attributes...'
total = geometries.size
completion_percentage = 0
new_completion_percentage = 0
puts 'PROGRESS BAR'
puts '_' * 100

geometries_data = geometries.map.with_index do |geo, i|
  # Progress bar

  new_completion_percentage = i * 100 / total
  if new_completion_percentage > completion_percentage
    completion_percentage = new_completion_percentage
    print '-'
  end

  # Geometry Data

  names = geo['ExtendedData']['SchemaData']['SimpleData']

  polygons_raw_data = [geo['MultiGeometry']['Polygon']].flatten

  polygons = polygons_raw_data.map do |polygon_raw_data|
    serialized_coordinate_pairs = polygon_raw_data['outerBoundaryIs']['LinearRing']['coordinates'].split

    points = serialized_coordinate_pairs.map do |serialized_coordinate_pair|
      RGeo::Cartesian.factory.point(*serialized_coordinate_pair.split(',').map(&:to_f))
    end
    line_string = RGeo::Cartesian.factory.line_string(points)

    RGeo::Cartesian.factory.polygon(line_string)
  end
  multi_polygon = RGeo::Cartesian.factory.multi_polygon(polygons)

  attributes = { data: multi_polygon }
  names.each_with_index { |name, i| attributes["name_#{i + 1}"] = name }
  attributes
end

puts
puts 'Writing Geometries to DB...'

Geometry.import geometries_data,
  on_duplicate_key_update: {
    conflict_target: %i[name_1 name_2 name_3 name_4],
    columns:         [:data]
  }

puts 'Geometries seeded...'
