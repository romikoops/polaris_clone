# frozen_string_literal: true

include ExcelTools
include MongoTools
# subdomains = %w(demo greencarrier easyshipping hartrodt)
subdomains = %w[easyshipping easyshipping-sandbox]
subdomains.each do |sub|
  # # Tenant.all.each do |tenant|
  tenant = Tenant.find_by_subdomain(sub)

  shipper = tenant.users.shipper.first
  tenant.itineraries.destroy_all
  tenant.local_charges.destroy_all
  tenant.customs_fees.destroy_all
  tps = tenant.trucking_pricings
  HubTrucking.where(trucking_pricing_id: tps.ids).delete_all
  tenant.trucking_pricings.delete_all
  tenant.hubs.destroy_all
  # # # #   # # # # #Overwrite hubs from excel sheet
  # puts '# Overwrite hubs from excel sheet'
  hubs = File.open("#{Rails.root}/db/dummydata/easyshipping/easyshipping__hubs.xlsx")
  req = { 'xlsx' => hubs }
  ExcelTool::HubsOverwriter.new(params: req, _user: shipper).perform

  public_pricings = File.open("#{Rails.root}/db/dummydata/easyshipping/easyshipping__freight_rates.xlsx")
  req = { 'xlsx' => public_pricings }
  ExcelTool::FreightRatesOverwriter.new(params: req, _user: shipper, generate: true).perform

  # # # # # #   # # # # # Overwrite public pricings from excel sheet

  puts '# Overwrite Local Charges From Sheet'
  local_charges = File.open("#{Rails.root}/db/dummydata/easyshipping/easyshipping__local_charges.xlsx")
  req = { 'xlsx' => local_charges }
  ExcelTool::OverwriteLocalCharges.new(params: req, user: shipper).perform

  # # # #   # # # # # # Overwrite trucking data from excel sheet

  # puts 'Copenhagen Port'
  hub = tenant.hubs.find_by_name('Copenhagen Port')
  trucking = File.open("#{Rails.root}/db/dummydata/easyshipping/easyshipping__trucking_ltl__copenhagen_port.xlsx")
  req = { 'xlsx' => trucking }
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  puts 'Copenhagen Railyard'
  # hub = tenant.hubs.find_by_name('Copenhagen Railyard')
  # trucking = File.open("#{Rails.root}/db/dummydata/easyshipping/easyshipping__trucking_ltl__copenhagen_port.xlsx")
  # req = { 'xlsx' => trucking }
  # # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  puts 'Copenhagen Port'
  hub = tenant.hubs.find_by_name('Copenhagen Port')
  trucking = File.open("#{Rails.root}/db/dummydata/easyshipping/easyshipping__trucking_ftl__copenhagen_port.xlsx")
  req = { 'xlsx' => trucking }
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  # puts 'Copenhagen Railyard'
  # hub = tenant.hubs.find_by_name('Copenhagen Railyard')
  # trucking = File.open("#{Rails.root}/db/dummydata/easyshipping/easyshipping__trucking_ftl__copenhagen_port.xlsx")
  # req = { 'xlsx' => trucking }
  # # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
end
