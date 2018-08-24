# frozen_string_literal: true

include ExcelTools
include MongoTools
# subdomains = %w(demo greencarrier easyshipping hartrodt)
subdomains = %w[saco-sandbox]
subdomains.each do |sub|
  # # Tenant.all.each do |tenant|
  tenant = Tenant.find_by_subdomain(sub)

  shipper = tenant.users.shipper.first
  tenant.itineraries.destroy_all
  tenant.local_charges.destroy_all
  tenant.customs_fees.destroy_all
  # # tenant.trucking_pricings.delete_all
  # tenant.hubs.destroy_all
  # tenant.nexuses.destroy_all
  # # # # #   # # # # #Overwrite hubs from excel sheet
  # puts '# Overwrite hubs from excel sheet'
  # hubs = File.open("#{Rails.root}/db/dummydata/saco/saco__hubs.xlsx")
  # req = { 'xlsx' => hubs }
  # ExcelTool::HubsOverwriter.new(params: req, _user: shipper).perform
  puts '# Overwrite pricings and rates from excel sheet'
  public_pricings = File.open("#{Rails.root}/db/dummydata/saco/saco__freight_rates.xlsx")
  req = { 'xlsx' => public_pricings }
  ExcelTool::FreightRatesOverwriter.new(params: req, _user: shipper, generate: true).perform

  # # # # # # # #   # # # # # Overwrite public pricings from excel sheet

  # # # # puts "# Overwrite Local Charges From Sheet"
  # local_charges = File.open("#{Rails.root}/db/dummydata/saco/saco__local_charges.xlsx")
  # req = { 'xlsx' => local_charges }
  # ExcelTool::OverwriteLocalCharges.new(params: req, user: shipper).perform

  # #   # # # # # # Overwrite trucking data from excel sheet

  # puts 'GS Warehouse LTL'
  # hub = tenant.hubs.find_by_name('GS Warehouse Depot')
  # trucking = File.open("#{Rails.root}/db/dummydata/gs_trucking_hamburg_ltl.xlsx")
  # req = { 'xlsx' => trucking }
  # # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  # awesome_print 'City rates done'
  # puts 'GS Warehouse LTL'
  # hub = tenant.hubs.find_by_name('GS Warehouse Depot')
  # trucking = File.open("#{Rails.root}/db/dummydata/gs_trucking_hamburg_ftl.xlsx")
  # req = { 'xlsx' => trucking }
  # # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  # awesome_print 'City rates done'

end
