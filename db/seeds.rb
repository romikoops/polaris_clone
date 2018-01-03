
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
  puts 'tenants'
  require './tenants'
  puts 'admin'
  require './admin'
  puts 'shipper'
  require './shipper'
  puts 'vehicle_types'
  require './vehicle_types'
  puts 'all_pricings'
  require './all_pricings'
end

