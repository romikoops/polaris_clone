include ExcelTools
include DocumentTools
include MongoTools
['demo'].each do |sub|
# # Tenant.all.each do |tenant|
  tenant = Tenant.find_by_subdomain(sub)
  
  shipper = tenant.users.where(role_id: 2).first
  tenant.itineraries.destroy_all
  tenant.local_charges.destroy_all
  tenant.customs_fees.destroy_all
	tenant.hubs.destroy_all
  #Overwrite hubs from excel sheet
  puts "# Overwrite hubs from excel sheet"
  hubs = File.open("#{Rails.root}/db/dummydata/SACO_ez_hubs.xlsx")
  req = {"xlsx" => hubs}
  overwrite_hubs(req, shipper)

  puts "# Overwrite public pricings from excel sheet"

  # public_pricings = File.open("#{Rails.root}/db/dummydata/SACO_FCL_STANDARD.xlsx")
  # req = {"xlsx" => public_pricings}
  # overwrite_freight_rates(req, shipper, true)
  public_pricings = File.open("#{Rails.root}/db/dummydata/standard_sheet.xlsx")
  req = {"xlsx" => public_pricings}
  overwrite_freight_rates(req, shipper, true)

  # # # Overwrite public pricings from excel sheet

  # puts "# Overwrite Local Charges From Sheet"
  # local_charges = File.open("#{Rails.root}/db/dummydata/SACO_local_charges.xlsx")
  # req = {"xlsx" => local_charges}
  # overwrite_local_charges(req, shipper)
  #  puts "# Overwrite Local Charges From Sheet"
  local_charges = File.open("#{Rails.root}/db/dummydata/local_charges.xlsx")
  req = {"xlsx" => local_charges}
  overwrite_local_charges(req, shipper)


  # # # # # Overwrite trucking data from excel sheet

 
  # hub = tenant.hubs.find_by_name("Shanghai Port")
  # trucking = File.open("#{Rails.root}/db/dummydata/gc_trucking_china.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # awesome_print "City rates done"
  # hub = tenant.hubs.find_by_name("Gothenburg Port")
  # trucking = File.open("#{Rails.root}/db/dummydata/gc_trucking_gothenburg.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # awesome_print "Zip rates done"
  
  # hub = tenant.hubs.find_by_name("Gothenburg Port")
  # trucking = File.open("#{Rails.root}/db/dummydata/gc_trucking_gothenburg_ftl.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # awesome_print "All rates done"

  # hub = tenant.hubs.find_by_name("Copenhagen Port")
  # trucking = File.open("#{Rails.root}/db/dummydata/es_trucking.xlsx")
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


  tenant.update_route_details()
end
