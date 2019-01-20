include ExcelTools
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
   HubTrucking.where(hub: tenant.hubs).delete_all
  tenant.hubs.destroy_all
  tenant.nexuses.destroy_all
# # # #   # # # # #Overwrite hubs from excel sheet
  puts "# Overwrite hubs from excel sheet"
  hubs = "data/trucking/trucking__hubs.xlsx"
  req = {"key" => hubs}
  ExcelTool::HubsOverwriter.new(params: req, _user: shipper).perform

  public_pricings = "data/trucking/trucking__freight_rates.xlsx"
  req = {"key" => public_pricings}
  ExcelTool::FreightRatesOverwriter.new(params: req, _user: shipper, generate: true).perform
# # # # # #   # # # # # Overwrite public pricings from excel sheet

  puts "# Overwrite Local Charges From Sheet"
    local_charges = "data/trucking/trucking__local_charges.xlsx"
    req = {"key" => local_charges}
    ExcelTool::OverwriteLocalCharges.new(params: req, user: shipper).perform


# # #   # # # # # # Overwrite trucking data from excel sheet

    # puts "Copenhagen Depot"
    # hub = tenant.hubs.find_by_name("Copenhagen Depot")
    # trucking = "data/trucking/es_trucking.xlsx"
    # req = {"key" => trucking}
    # # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
    # ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
    puts "Hamburg Depot"
    hub = tenant.hubs.find_by_name("Hamburg Depot")
    trucking = "data/trucking/trucking__trucking_ltl__hamburg_port.xlsx"
    req = {"key" => trucking}
    # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
    ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
    puts "Hamburg Depot"
    hub = tenant.hubs.find_by_name("Hamburg Depot")
    trucking = "data/trucking/trucking__trucking_ftl__hamburg_port.xlsx"
    req = {"key" => trucking}
    # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
    ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
    puts "Gothenburg Depot ftl"
    hub = tenant.hubs.find_by_name("Gothenburg Depot")
    trucking = "data/trucking/trucking__trucking_ftl__gothenburg_port.xlsx"
    req = {"key" => trucking}
    # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
    ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
    puts "Gothenburg Depot ltl"
    hub = tenant.hubs.find_by_name("Gothenburg Depot")
    trucking = "data/trucking/trucking__trucking_ltl__gothenburg_port.xlsx"
    req = {"key" => trucking}
    # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
    ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
    awesome_print "City rates done"
end
