# frozen_string_literal: true

include ExcelTools
include MongoTools

puts 'You called rake \'db:seed:demo\'.'
puts 'This task will load all seed files, but only the pricings for \'demo\'.'
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
  puts 'incoterms'
  require './incoterms'
  puts 'cargo_item_types'
  require './cargo_item_types'
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
  puts 'all_pricings_demo'
  require './all_pricings_demo'
  puts 'distributions'
  require './distributions'
end

puts 'tenants'
require "#{Rails.root}/db/seed_classes/tenant_seeder.rb"
TenantSeeder.exec
