# frozen_string_literal: true

include ExcelTools
# subdomains = %w(demo greencarrier easyshipping hartrodt)
subdomains = %w[demo]
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
  # # # #   # # # # #Overwrite hubs from excel sheet
  # # # puts '# Overwrite hubs from excel sheet'
  hubs = "data/demo/demo__hubs.xlsx"
  req = { 'key' => hubs }
  ExcelTool::HubsOverwriter.new(params: req, _user: shipper).perform

  public_pricings = "data/demo/demo__freight_rates.xlsx"
  req = { 'key' => public_pricings }
  ExcelTool::FreightRatesOverwriter.new(params: req, _user: shipper, generate: true).perform

  # # # # # # # #   # # # # # Overwrite public pricings from excel sheet

  # # # # puts "# Overwrite Local Charges From Sheet"
  local_charges = "data/demo/demo__local_charges.xlsx"
  req = { 'key' => local_charges }
  ExcelTool::OverwriteLocalCharges.new(params: req, user: shipper).perform

  # #   # # # # # # Overwrite trucking data from excel sheet

  puts 'Shanghai Airport'
  hub = tenant.hubs.find_by_name('Shanghai Airport')
  trucking = "data/greencarrier/greencarrier__trucking_ltl__shanghai_port.xlsx"
  req = { 'key' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(
    params: req, _user: shipper, hub_id: hub.id
  ).perform
  puts 'Shanghai Port'
  hub = tenant.hubs.find_by_name('Shanghai Port')
  trucking = "data/greencarrier/greencarrier__trucking_ltl__shanghai_port.xlsx"
  req = { 'key' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  puts 'Shanghai Airport ftl'
  hub = tenant.hubs.find_by_name('Shanghai Port')
  trucking = "data/greencarrier/greencarrier__trucking_ftl__shanghai_port.xlsx"
  req = { 'key' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(
          params: req, _user: shipper, hub_id: hub.id
        ).perform
  awesome_print 'City rates done'
  puts 'Gothenburg Port'
  hub = tenant.hubs.find_by_name('Gothenburg Port')
  trucking = "data/greencarrier/greencarrier__trucking_ltl__gothenburg_port.xlsx"
  req = { 'key' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(
          params: req, _user: shipper, hub_id: hub.id
        ).perform
  puts 'Gothenburg Airport'
  hub = tenant.hubs.find_by_name('Gothenburg Airport')
  trucking = "data/greencarrier/greencarrier__trucking_ltl__gothenburg_airport.xlsx"
  req = { 'key' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(
          params: req, _user: shipper, hub_id: hub.id
        ).perform
  awesome_print 'Zip rates done'
  puts 'Gothenburg Port ftl'
  hub = tenant.hubs.find_by_name('Gothenburg Port')
  trucking = "data/greencarrier/greencarrier__trucking_ftl__gothenburg_port.xlsx"
  req = { 'key' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(
          params: req, _user: shipper, hub_id: hub.id
        ).perform
  awesome_print 'All rates done'
  puts 'Stockholm Airport'
  hub = tenant.hubs.find_by_name('Stockholm Airport')
  trucking = "data/greencarrier/greencarrier__trucking_ltl__stockholm_airport.xlsx"
  req = { 'key' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(
          params: req, _user: shipper, hub_id: hub.id
        ).perform
  puts 'Malmo Airport'
  hub = tenant.hubs.find_by_name('Malmo Airport')
  trucking = "data/greencarrier/greencarrier__trucking_ltl__malmo_airport.xlsx"
  req = { 'key' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(
          params: req, _user: shipper, hub_id: hub.id
        ).perform
end
