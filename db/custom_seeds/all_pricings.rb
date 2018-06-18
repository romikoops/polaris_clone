# frozen_string_literal: true

require "#{Rails.root}/db/seed_classes/pricing_seeder.rb"
PricingSeeder.perform
