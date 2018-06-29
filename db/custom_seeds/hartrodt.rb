# frozen_string_literal: true
include ExcelTools
include MongoTools
# subdomains = %w(demo greencarrier easyshipping hartrodt)
subdomains = %w[saco saco-sandbox]
subdomains.each do |sub|
  tenant = Tenant.find_by_subdomain(sub)
  shipper = tenant.users.shipper.first
  puts '# Overwrite hubs from excel sheet'
  hubs = File.open("#{Rails.root}/db/dummydata/ht_hubs.xlsx")
  req = { 'xlsx' => hubs }
  overwrite_hubs(req, shipper)
  public_pricings = File.open("#{Rails.root}/db/dummydata/NEW_hartrodt_rates.xlsx")
  req = { 'xlsx' => public_pricings }
  overwrite_freight_rates(req, shipper, true)
  puts '# Overwrite Local Charges From Sheet'
  local_charges = File.open("#{Rails.root}/db/dummydata/ht_local_charges.xlsx")
  req = { 'xlsx' => local_charges }
  ExcelTool::OverwriteLocalCharges.new(params: req, user: shipper).perform

  hub = tenant.hubs.find_by_name('Hamburg Port')
  trucking = File.open("#{Rails.root}/db/dummydata/new_ht_trucking_hamburg_ftl.xlsx")
  req = { 'xlsx' => trucking }
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  trucking = File.open("#{Rails.root}/db/dummydata/new_ht_trucking_hamburg_ltl.xlsx")
  req = { 'xlsx' => trucking }
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  hub = tenant.hubs.find_by_name('Frankfurt Airport')
  trucking = File.open("#{Rails.root}/db/dummydata/new_ht_trucking_hamburg_ftl.xlsx")
  req = { 'xlsx' => trucking }
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  trucking = File.open("#{Rails.root}/db/dummydata/new_ht_trucking_hamburg_ltl.xlsx")
  req = { 'xlsx' => trucking }
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  hub = tenant.hubs.find_by_name('Hamburg Airport')
  trucking = File.open("#{Rails.root}/db/dummydata/new_ht_trucking_hamburg_ftl.xlsx")
  req = { 'xlsx' => trucking }
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  trucking = File.open("#{Rails.root}/db/dummydata/new_ht_trucking_hamburg_ltl.xlsx")
  req = { 'xlsx' => trucking }
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
end