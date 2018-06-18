# frozen_string_literal: true

require "#{Rails.root}/db/seed_classes/trucking_pricing_seeder.rb"

TruckingPricingSeeder.perform(subdomain: 'demo')
TruckingPricingSeeder.perform(subdomain: 'greencarrier')
# TruckingPricingSeeder.perform(subdomain: 'easyshipping')
# TruckingPricingSeeder.perform(subdomain: 'hartrodt')
# TruckingPricingSeeder.perform(subdomain: 'saco')
