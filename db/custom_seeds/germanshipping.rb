# frozen_string_literal: true

include ExcelTools
include MongoTools
# subdomains = %w(demo greencarrier easyshipping hartrodt)
subdomains = %w[german-shipping]
subdomains.each do |sub|
  # # Tenant.all.each do |tenant|
  tenant = Tenant.find_by_subdomain(sub)

  shipper = tenant.users.shipper.first
  tenant.itineraries.destroy_all
  # tenant.local_charges.destroy_all
  # tenant.customs_fees.destroy_all
  # # # tenant.trucking_pricings.delete_all
  # tenant.hubs.destroy_all
  # # # #   # # # # #Overwrite hubs from excel sheet
  # # # puts '# Overwrite hubs from excel sheet'
  hubs = File.open("#{Rails.root}/db/dummydata/german-shipping/german-shipping__hubs.xlsx")
  req = { 'xlsx' => hubs }
  ExcelTool::HubsOverwriter.new(params: req, _user: shipper).perform

  public_pricings = File.open("#{Rails.root}/db/dummydata/german-shipping/german-shipping__freight_rates.xlsx")
  req = { 'xlsx' => public_pricings }
  overwrite_freight_rates(req, shipper, true)

  # # # # # # # #   # # # # # Overwrite public pricings from excel sheet

  # # # # puts "# Overwrite Local Charges From Sheet"
  # local_charges = File.open("#{Rails.root}/db/dummydata/gc_local_charges.xlsx")
  # req = { 'xlsx' => local_charges }
  # overwrite_local_charges(req, shipper)

  # #   # # # # # # Overwrite trucking data from excel sheet

  puts 'GS Warehouse LTL'
  hub = tenant.hubs.find_by_name('GS Warehouse Depot')
  trucking = File.open("#{Rails.root}/db/dummydata/german-shipping/german-shipping__trucking_ltl__hamburg_depot.xlsx")
  req = { 'xlsx' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  awesome_print 'City rates done'
  puts 'GS Warehouse LTL'
  hub = tenant.hubs.find_by_name('GS Warehouse Depot')
  trucking = File.open("#{Rails.root}/db/dummydata/german-shipping/german-shipping__trucking_ftl__hamburg_depot.xlsx")
  req = { 'xlsx' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  awesome_print 'City rates done'

end
