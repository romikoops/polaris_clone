include ExcelTools
include DocumentTools
include MongoTools
# subdomains = %w(demo greencarrier easyshipping hartrodt)
subdomains = %w(demo)
subdomains.each do |sub|
# # Tenant.all.each do |tenant|
  tenant = Tenant.find_by_subdomain(sub)
  
  shipper = tenant.users.where(role_id: 2).first
#   tenant.itineraries.destroy_all
#   tenant.local_charges.destroy_all
#   tenant.customs_fees.destroy_all
 
#   tenant.trucking_pricings.delete_all
#   # tenant.hub_truckings.delete_all
#   tenant.hubs.destroy_all
#   # # # # #Overwrite hubs from excel sheet
#   puts "# Overwrite hubs from excel sheet"
  # hubs = File.open("#{Rails.root}/db/dummydata/MOL_hubs.xlsx")
  # req = {"xlsx" => hubs}
  # overwrite_hubs(req, shipper)

# #   # # # # puts "# Overwrite public pricings from excel sheet"

  # public_pricings = File.open("#{Rails.root}/db/dummydata/hartrodt_rates.xlsx")
  # req = {"xlsx" => public_pricings}
  # overwrite_freight_rates(req, shipper, true)
# #   # public_pricings = File.open("#{Rails.root}/db/dummydata/standard_sheet.xlsx")
# #   # req = {"xlsx" => public_pricings}
# #   # overwrite_freight_rates(req, shipper, true)

# #   # # # # # Overwrite public pricings from excel sheet

  # puts "# Overwrite Local Charges From Sheet"
  # local_charges = File.open("#{Rails.root}/db/dummydata/ht_local_charges.xlsx")
  # req = {"xlsx" => local_charges}
# #   # # overwrite_local_charges(req, shipper)
# #   #  puts "# Overwrite Local Charges From Sheet"
# #   local_charges = File.open("#{Rails.root}/db/dummydata/ht_local_charges.xlsx")
# #   req = {"xlsx" => local_charges}
# #   overwrite_local_charges(req, shipper)


#   # # # # # # Overwrite trucking data from excel sheet

 
#   # hub = tenant.hubs.find_by_name("Shanghai Port")
#   # trucking = File.open("#{Rails.root}/db/dummydata/gc_trucking_china.xlsx")
#   # req = {"xlsx" => trucking}
#   # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
#   # awesome_print "City rates done"
#   # hub = tenant.hubs.find_by_name("Gothenburg Airport")
#   # trucking = File.open("#{Rails.root}/db/dummydata/gc_trucking_gothenburg.xlsx")
#   # req = {"xlsx" => trucking}
#   # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
#   # awesome_print "Zip rates done"
#   # hub = tenant.hubs.find_by_name("Malmo Airport")
#   # trucking = File.open("#{Rails.root}/db/dummydata/gc_trucking_gothenburg.xlsx")
#   # req = {"xlsx" => trucking}
#   # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
#   # awesome_print "Zip rates done"
  
  # hub = tenant.hubs.find_by_name("Shanghai Port")
  # trucking = File.open("#{Rails.root}/db/dummydata/ht_trucking_shanghai_ftl.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # awesome_print "All rates done"
  
  # hub = tenant.hubs.find_by_name("Shanghai Airport")
  # trucking = File.open("#{Rails.root}/db/dummydata/ht_trucking_shanghai_ftl.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # awesome_print "All rates done"

  hub = tenant.hubs.find_by_name("Hamburg Airport")
  # trucking = File.open("#{Rails.root}/db/dummydata/ht_trucking_hamburg_ftl.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  trucking = File.open("#{Rails.root}/db/dummydata/ht_trucking_hamburg_ltl.xlsx")
  req = {"xlsx" => trucking}
  overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)

  # hub = tenant.hubs.find_by_name("Frankfurt Airport")
  # trucking = File.open("#{Rails.root}/db/dummydata/ht_trucking_hamburg_ftl.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # trucking = File.open("#{Rails.root}/db/dummydata/ht_trucking_hamburg_ltl.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)

  #  hub = tenant.hubs.find_by_name("Hamburg Airport")
  # trucking = File.open("#{Rails.root}/db/dummydata/ht_trucking_hamburg_ftl.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # trucking = File.open("#{Rails.root}/db/dummydata/ht_trucking_hamburg_ltl.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)


    # hub = tenant.hubs.find_by_name("Antwerpen Port")
    # trucking = File.open("#{Rails.root}/db/dummydata/saco_trucking_antwerpen_ftl.xlsx")
    # req = {"xlsx" => trucking}
    # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)

    # hub = tenant.hubs.find_by_name("Rotterdam Port")
    # trucking = File.open("#{Rails.root}/db/dummydata/saco_trucking_rotterdam_ftl.xlsx")
    # req = {"xlsx" => trucking}
    # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)

    # hub = tenant.hubs.find_by_name("Hamburg Port")
    # trucking = File.open("#{Rails.root}/db/dummydata/saco_trucking_hamburg_ftl.xlsx")
    # req = {"xlsx" => trucking}
    # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
    # gothenburg_options_ltl = {
    #   tenant_id: 2,
    #   hub_id: 1,
    #   load_type: 'cargo_item'
    # }
    # gothenburg_options_ftl = {
    #   tenant_id: 2,
    #   hub_id: 1,
    #   load_type: 'container'
    # }
    # shanghai_options = {
    #   tenant_id: 2,
    #   hub_id: 3,
    #   load_type: 'cargo_item'
    # }
    # # gothenburg_ltl_url = write_trucking_to_sheet(gothenburg_options_ltl)
    # #  awesome_print gothenburg_ltl_url
    # gothenburg_ftl_url = write_trucking_to_sheet(gothenburg_options_ftl)
    #  awesome_print gothenburg_ftl_url
    # shanghai_ltl_url = write_trucking_to_sheet(shanghai_options)
    #  awesome_print shanghai_ltl_url
    # admin_sea = tenant.users.new(
    #   role: Role.find_by_name('admin'),

    #   company_name: tenant.name,
    #   first_name: "Ocean Freight",
    #   last_name: "Admin",
    #   phone: "+46 31-85 32 00",

    #   email: "imc.sea.se@greencarrier.se",
    #   password: "oceanfreightadmin",
    #   password_confirmation: "oceanfreightadmin",

    #   confirmed_at: DateTime.new(2017, 1, 20)
    # )
    # # admin.skip_confirmation!
    # admin_sea.save!
    # admin_air = tenant.users.new(
    #   role: Role.find_by_name('admin'),

    #   company_name: tenant.name,
    #   first_name: "Air Freight",
    #   last_name: "Admin",
    #   phone: "+46 31-85 32 00",

    #   email: "imc.air.se@greencarrier.se",
    #   password: "airfreightadmin",
    #   password_confirmation: "airfreightadmin",

    #   confirmed_at: DateTime.new(2017, 1, 20)
    # )
    # # admin.skip_confirmation!
    # admin_air.save!
   
  # tenant.update_route_details()
end
