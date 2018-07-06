# frozen_string_literal: true
include ExcelTools
include MongoTools
# subdomains = %w(demo greencarrier easyshipping hartrodt)
subdomains = %w[hartrodt hartrodt-sandbox]
subdomains.each do |sub|
  tenant = Tenant.find_by_subdomain(sub)
  shipper = tenant.users.shipper.first
  puts '# Overwrite hubs from excel sheet'
  hubs = File.open("#{Rails.root}/db/dummydata/hartrodt/hartrodt__hubs.xlsx")
  req = { 'xlsx' => hubs }
  ExcelTool::HubsOverwriter.new(params: req, _user: shipper).perform
  public_pricings = File.open("#{Rails.root}/db/dummydata/hartrodt/hartrodt__rates.xlsx")
  req = { 'xlsx' => public_pricings }
  overwrite_freight_rates(req, shipper, true)
  puts '# Overwrite Local Charges From Sheet'
  local_charges = File.open("#{Rails.root}/db/dummydata/hartrodt/hartrodt__local_charges.xlsx")
  req = { 'xlsx' => local_charges }
  ExcelTool::OverwriteLocalCharges.new(params: req, user: shipper).perform

  hub = tenant.hubs.find_by_name('Hamburg Port')
  trucking = File.open("#{Rails.root}/db/dummydata/hartrodt/hartrodt__trucking_ftl__hamburg_port.xlsx")
  req = { 'xlsx' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  trucking = File.open("#{Rails.root}/db/dummydata/hartrodt/hartrodt__trucking_ltl__hamburg_port.xlsx")
  req = { 'xlsx' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  hub = tenant.hubs.find_by_name('Shanghai Port')
  trucking = File.open("#{Rails.root}/db/dummydata/hartrodt/hartrodt__trucking_ftl__shanghai_port.xlsx")
  req = { 'xlsx' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
end