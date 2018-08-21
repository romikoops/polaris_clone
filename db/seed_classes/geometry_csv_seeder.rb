# frozen_string_literal: true

require "csv"

class GeometryCsvSeeder
  def self.perform
    puts "Reading from csv..."

    Zlib::GzipReader.open(Rails.root.join("db/dummydata/germany.csv.gz")) do |gz|
      csv = CSV.new(gz, headers: true)
      csv.each do |row|
        geometry_data = {
          name_1: "#{row['city']} #{row['name']}",
          name_2: "#{row['city']} #{row['name']}",
          name_3: "#{row['city']} #{row['name']}",
          name_4: "#{row['city']} #{row['name']}",
          data:   RGeo::GeoJSON.decode(row["geojson"])
        }

        Geometry.import([geometry_data],
          on_duplicate_key_update: {
            conflict_target: %i(name_1 name_2 name_3 name_4),
            columns:         %i(data)
          })
      end
    end

    puts "Germany Geometries seeded..."
  end
end
