# frozen_string_literal: true

require "csv"

class GeometryCsvSeeder
  def self.perform
    puts "Reading from csv..."

    Zlib::GzipReader.open(Rails.root.join("db/dummydata/locations.csv.gz")) do |gz|
      csv = CSV.new(gz, headers: true)
      csv.each do |row|
        geometry_data = {
          name_1: row['name'],
          name_2: row['name_1'],
          name_3: row['name_2'],
          name_4: row['name_3'],
          data:   row["geojson"]
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
