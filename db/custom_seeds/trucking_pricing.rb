require "#{Rails.root}/db/seed_classes/trucking_pricing_seeder.rb"

TruckingPricingSeeder.exec(subdomain: 'demo')