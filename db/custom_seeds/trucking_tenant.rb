include ExcelTools
include MongoTools
# subdomains = %w(demo greencarrier easyshipping hartrodt)
subdomains = %w(trucking trucking-sandbox)
subdomains.each do |sub|
# # Tenant.all.each do |tenant|
  tenant = Tenant.find_by_subdomain(sub)

  shipper = tenant.users.shipper.first
  tenant.itineraries.destroy_all
   tenant.local_charges.destroy_all
   tenant.customs_fees.destroy_all
   tenant.trucking_pricings.delete_all
  tenant.hubs.destroy_all
# # # #   # # # # #Overwrite hubs from excel sheet
  puts "# Overwrite hubs from excel sheet"
  hubs = File.open("#{Rails.root}/db/dummydata/trucking_hubs.xlsx")
  req = {"xlsx" => hubs}
  overwrite_hubs(req, shipper)

  public_pricings = File.open("#{Rails.root}/db/dummydata/trucking_freight_rates.xlsx")
  req = {"xlsx" => public_pricings}
  overwrite_freight_rates(req, shipper, true)

# # # # # #   # # # # # Overwrite public pricings from excel sheet

  puts "# Overwrite Local Charges From Sheet"
    local_charges = File.open("#{Rails.root}/db/dummydata/trucking_local_charges.xlsx")
    req = {"xlsx" => local_charges}
    ExcelTool::OverwriteLocalCharges.new(params: req, user: shipper).perform


# # #   # # # # # # Overwrite trucking data from excel sheet

    puts "Copenhagen Depot"
    hub = tenant.hubs.find_by_name("Copenhagen Depot")
    trucking = File.open("#{Rails.root}/db/dummydata/es_trucking.xlsx")
    req = {"xlsx" => trucking}
    # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
    ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
    puts "Hamburg Depot"
    hub = tenant.hubs.find_by_name("Hamburg Depot")
    trucking = File.open("#{Rails.root}/db/dummydata/trucking_trucking_hamburg_ltl.xlsx")
    req = {"xlsx" => trucking}
    # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
    ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
    puts "Hamburg Depot"
    hub = tenant.hubs.find_by_name("Hamburg Depot")
    trucking = File.open("#{Rails.root}/db/dummydata/trucking_trucking_hamburg_port_ftl.xlsx")
    req = {"xlsx" => trucking}
    # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
    ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
    puts "Gothenburg Depot ftl"
    hub = tenant.hubs.find_by_name("Gothenburg Depot")
    trucking = File.open("#{Rails.root}/db/dummydata/trucking_trucking_gothenburg_port_ftl.xlsx")
    req = {"xlsx" => trucking}
    # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
    ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
    puts "Gothenburg Depot ltl"
    hub = tenant.hubs.find_by_name("Gothenburg Depot")
    trucking = File.open("#{Rails.root}/db/dummydata/trucking_trucking_gothenburg_port.xlsx")
    req = {"xlsx" => trucking}
    # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
    ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
    awesome_print "City rates done"
end
