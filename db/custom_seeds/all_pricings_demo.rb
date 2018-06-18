# frozen_string_literal: true

require "#{Rails.root}/db/seed_classes/pricing_seeder.rb"
PricingSeeder.perform(subdomain: 'demo')
PricingSeeder.perform(subdomain: 'greencarrier')
# PricingSeeder.perform(subdomain: 'hartrodt')
# PricingSeeder.perform(subdomain: 'saco')
