
# frozen_string_literal: true

include ExcelTools

puts 'You called rake \'db:seed\'. This task will load all seed files.'
puts 'Load individual seeds with (e.g.) \'rake db:seed:all_pricings \''
puts 'Start seeding...'

Dir.chdir("#{Rails.root}/db/custom_seeds/") do
  puts 'drop_tables'
  require './drop_tables'
  puts 'countries'
  require './countries'
  puts 'mot_scopes'
  require './mot_scopes'
  puts 'optin_statuses'
  require './optin_statuses'
  puts 'roles'
  require './roles'
  puts 'cargo_item_types'
  require './cargo_item_types'
  puts 'trucking_destinations'
  require './trucking_destinations'
  puts 'tenants'
  require './tenants'
  puts 'admin'
  require './admin'
  puts 'super_admin'
  require './super_admin'
  puts 'shipper'
  require './shipper'
  puts 'vehicles'
  require './vehicles'
  puts 'all_pricings'
  require './all_pricings'
  puts 'distributions'
  require './distributions'
  # puts 'demo_seed'
  # require './demo_seed'
  # puts 'hs_codes'
  # require './hs_code'
end

puts 'tenants'
require "#{Rails.root}/db/seed_classes/tenant_seeder.rb"
TenantSeeder.perform
