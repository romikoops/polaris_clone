# frozen_string_literal: true

include ExcelTools
# subdomains = %w(demo greencarrier easyshipping hartrodt)
subdomains = %w(hartrodt hartrodt-sandbox)
subdomains.each do |sub|
  tenant = Tenant.find_by_subdomain(sub)
  shipper = tenant.users.shipper.first
  puts '# Overwrite hubs from excel sheet'
  hubs = 'data/hartrodt/hartrodt__hubs.xlsx'
  req = { 'key' => hubs }
  ExcelTool::HubsOverwriter.new(params: req, _user: shipper).perform
  public_pricings = 'data/hartrodt/hartrodt__rates.xlsx'
  req = { 'key' => public_pricings }
  ExcelTool::FreightRatesOverwriter.new(params: req, _user: shipper, generate: true).perform
  puts '# Overwrite Local Charges From Sheet'
  local_charges = 'data/hartrodt/hartrodt__local_charges.xlsx'
  req = { 'key' => local_charges }
  ExcelTool::OverwriteLocalCharges.new(params: req, user: shipper).perform

  hub = tenant.hubs.find_by_name('Hamburg Port')
  trucking = 'data/hartrodt/hartrodt__trucking_ftl__hamburg_port.xlsx'
  req = { 'key' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  trucking = 'data/hartrodt/hartrodt__trucking_ltl__hamburg_port.xlsx'
  req = { 'key' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  hub = tenant.hubs.find_by_name('Shanghai Port')
  trucking = 'data/hartrodt/hartrodt__trucking_ftl__shanghai_port.xlsx'
  req = { 'key' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
end
