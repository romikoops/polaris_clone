# frozen_string_literal: true

include ExcelTools
include MongoTools
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
  hubs = File.open("#{Rails.root}/db/dummydata/demo/demo__hubs.xlsx")
  req = { 'xlsx' => hubs }
  overwrite_hubs(req, shipper)

  public_pricings = File.open("#{Rails.root}/db/dummydata/demo/demo__freight_rates.xlsx")
  req = { 'xlsx' => public_pricings }
  overwrite_freight_rates(req, shipper, true)

  # # # # # # # #   # # # # # Overwrite public pricings from excel sheet

  # # # # puts "# Overwrite Local Charges From Sheet"
  local_charges = File.open("#{Rails.root}/db/dummydata/demo/demo__local_charges.xlsx")
  req = { 'xlsx' => local_charges }
  overwrite_local_charges(req, shipper)

  # #   # # # # # # Overwrite trucking data from excel sheet

  puts 'Shanghai Airport'
  hub = tenant.hubs.find_by_name('Shanghai Airport')
  trucking = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__trucking_ltl__shanghai_port.xlsx")
  req = { 'xlsx' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(
    params: req, _user: shipper, hub_id: hub.id
  ).perform
  puts 'Shanghai Port'
  hub = tenant.hubs.find_by_name('Shanghai Port')
  trucking = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__trucking_ltl__shanghai_port.xlsx")
  req = { 'xlsx' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(
          params: req, _user: shipper, hub_id: hub.id
        ).perform
  puts 'Shanghai Airport ftl'
  hub = tenant.hubs.find_by_name('Shanghai Port')
  trucking = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__trucking_ftl__shanghai_port.xlsx")
  req = { 'xlsx' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(
          params: req, _user: shipper, hub_id: hub.id
        ).perform
  awesome_print 'City rates done'
  puts 'Gothenburg Port'
  hub = tenant.hubs.find_by_name('Gothenburg Port')
  trucking = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__trucking_ltl__gothenburg_port.xlsx")
  req = { 'xlsx' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(
          params: req, _user: shipper, hub_id: hub.id
        ).perform
  puts 'Gothenburg Airport'
  hub = tenant.hubs.find_by_name('Gothenburg Airport')
  trucking = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__trucking_ltl__gothenburg_airport.xlsx")
  req = { 'xlsx' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(
          params: req, _user: shipper, hub_id: hub.id
        ).perform
  awesome_print 'Zip rates done'
  puts 'Gothenburg Port ftl'
  hub = tenant.hubs.find_by_name('Gothenburg Port')
  trucking = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__trucking_ftl__gothenburg_port.xlsx")
  req = { 'xlsx' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(
          params: req, _user: shipper, hub_id: hub.id
        ).perform
  awesome_print 'All rates done'
  puts 'Stockholm Airport'
  hub = tenant.hubs.find_by_name('Stockholm Airport')
  trucking = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__trucking_ltl__stockholm_airport.xlsx")
  req = { 'xlsx' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(
          params: req, _user: shipper, hub_id: hub.id
        ).perform
  puts 'Malmo Airport'
  hub = tenant.hubs.find_by_name('Malmo Airport')
  trucking = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__trucking_ltl__malmo_airport.xlsx")
  req = { 'xlsx' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(
          params: req, _user: shipper, hub_id: hub.id
        ).perform
end
