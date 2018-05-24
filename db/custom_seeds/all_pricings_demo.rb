require "#{Rails.root}/db/seed_classes/pricing_seeder.rb"
PricingSeeder.exec(subdomain: 'demo')
PricingSeeder.exec(subdomain: 'greencarrier')
# PricingSeeder.exec(subdomain: 'hartrodt')
# PricingSeeder.exec(subdomain: 'saco')
