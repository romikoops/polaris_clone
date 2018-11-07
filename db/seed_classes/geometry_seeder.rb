# frozen_string_literal: true

class GeometrySeeder
  TMP_PATH = 'tmp/tmp_kml.kml'
  def self.perform
    puts 'Reading from kml...'
    GeometrySeeder.get_s3_file('data/china.kml')
    geometry_hash = Hash.from_xml(File.open(TMP_PATH))
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

      attributes = { 
        bounds: multi_polygon,
        postal_code: '',
        neighbourhood: names[3],
        city: names[2],
        province: names[1],
        country: names[0]
      }
      # binding.pry
      # names.each_with_index { |name, i| attributes["name_#{i + 1}"] = name }

      attributes
    end

    puts
    puts 'Writing Geometries to DB...'

    Location.import geometries_data,
                    on_duplicate_key_update: {
                      conflict_target: %i(postal_code suburb neighbourhood city province country),
                      columns:         [:bounds]
                    }

    File.delete(TMP_PATH) if File.exist?(TMP_PATH)

    puts 'Geometries seeded...'
  end

  def self.get_s3_file(key)
    s3 = Aws::S3::Client.new

    file = s3.get_object(
      bucket: 'assets.itsmycargo.com',
      key: key
    ).body.read

    File.open(TMP_PATH, 'wb') { |f| f.write(file) }
  end
end
