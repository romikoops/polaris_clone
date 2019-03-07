# frozen_string_literal: true

include ExcelTools
subdomains = %w(normanglobal normanglobal-sandbox)
subdomains.each do |sub|
  # # Tenant.all.each do |tenant|
  tenant = Tenant.find_by_subdomain(sub)

  shipper = tenant.users.shipper.first
  tenant.itineraries.destroy_all
  tenant.local_charges.destroy_all
  tenant.customs_fees.destroy_all
  tenant.trucking_pricings.delete_all
  HubTrucking.where(hub_id: tenant.hubs).delete_all
  tenant.hubs.destroy_all

  # #   # # # # #Overwrite hubs from excel sheet
  puts '# Overwrite hubs from excel sheet'
  hubs = 'data/normanglobal/normanglobal__hubs.xlsx'
  req = { 'key' => hubs }
  ExcelTool::HubsOverwriter.new(params: req, _user: shipper).perform

  puts '# Overwrite freight rates from excel sheet'
  public_pricings = 'data/normanglobal/normanglobal__freight_rates.xlsx'
  req = { 'key' => public_pricings }
  ExcelTool::FreightRatesOverwriter.new(params: req, _user: shipper, generate: true).perform

  # # # #   # # # # # Overwrite public pricings from excel sheet

  puts '# Overwrite Local Charges From Sheet'
  local_charges = 'data/normanglobal/normanglobal__local_charges.xlsx'
  req = { 'key' => local_charges }
  ExcelTool::OverwriteLocalCharges.new(params: req, user: shipper).perform
  # #   # # # # # # Overwrite trucking data from excel sheet

  puts '# Overwrite Trucking  From Sheet'

  puts '! Shanghai Port'
  hub = tenant.hubs.find_by_name('Shanghai Port')
  trucking = "data/normanglobal/normanglobal__trucking_ltl__shanghai_port.xlsx"
  req = { 'key' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform

  puts '! Dalian Port'
  hub = tenant.hubs.find_by_name('Dalian Port')
  trucking = 'data/normanglobal/normanglobal__trucking_ltl__china_default.xlsx'
  req = { 'key' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform

  puts '! Qingdao Port'
  hub = tenant.hubs.find_by_name('Qingdao Port')
  trucking = 'data/normanglobal/normanglobal__trucking_ltl__china_default.xlsx'
  req = { 'key' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform

  puts '! Shenzhen Port'
  hub = tenant.hubs.find_by_name('Shenzhen Port')
  trucking = 'data/normanglobal/normanglobal__trucking_ltl__china_default.xlsx'
  req = { 'key' => trucking }
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
end
