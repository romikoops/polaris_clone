require "#{Rails.root}/db/seed_classes/trucking_pricing_seeder.rb"

TruckingPricingSeeder.exec(subdomain: 'demo')
TruckingPricingSeeder.exec(subdomain: 'greencarrier')
# TruckingPricingSeeder.exec(subdomain: 'easyshipping')
# TruckingPricingSeeder.exec(subdomain: 'hartrodt')
# TruckingPricingSeeder.exec(subdomain: 'saco')