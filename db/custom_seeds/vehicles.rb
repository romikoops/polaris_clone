# frozen_string_literal: true

require "#{Rails.root}/db/seed_classes/vehicle_seeder.rb"
VehicleSeeder.perform
