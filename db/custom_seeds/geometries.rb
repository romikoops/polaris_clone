# frozen_string_literal: true

# require "#{Rails.root}/db/seed_classes/geometry_seeder.rb"
require "#{Rails.root}/db/seed_classes/geometry_csv_seeder.rb"
require "#{Rails.root}/db/seed_classes/location_csv_seeder.rb"

# GeometrySeeder.perform
# GeometryCsvSeeder.perform
LocationCsvSeeder.perform
