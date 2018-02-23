
include ExcelTools
include MongoTools


puts 'You called rake \'db:seed\'. This task will load all seed files.'
puts 'Load individual seeds with (e.g.) \'rake db:seed:all_pricings \''
puts 'Start seeding...'

Dir.chdir("#{Rails.root}/db/custom_seeds/") do

  puts 'drop_tables'
  require './drop_tables'
  puts 'mot_scopes'
  require './mot_scopes'
  puts 'roles'
  require './roles'
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
  puts 'vehicle_types'
  require './vehicle_types'
  puts 'drop_all_pricings'
  require './drop_all_pricings'
  # puts 'all_pricings'
  # require './all_pricings'
  puts 'demo_seed'
  require './demo_seed'
  # puts 'hs_codes'
  # require './hs_code'
end

