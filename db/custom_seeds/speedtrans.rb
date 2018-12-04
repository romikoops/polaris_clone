# frozen_string_literal: true

include ExcelTools
include MongoTools
# subdomains = %w(demo greencarrier easyshipping hartrodt)
subdomains = %w(speedtrans speedtrans-sandbox)
subdomains.each do |sub|
  # # Tenant.all.each do |tenant|
  tenant = Tenant.find_by_subdomain(sub)

  shipper = tenant.users.shipper.first
  # tenant.itineraries.destroy_all
  # tenant.local_charges.destroy_all
  # tenant.customs_fees.destroy_all
  # tenant.trucking_pricings.delete_all
  # HubTrucking.where(hub_id: tenant.hubs).delete_all
  # tenant.hubs.destroy_all
  # Addon.destroy_all
  # # #   # # # # #Overwrite hubs from excel sheet
  # puts '# Overwrite hubs from excel sheet'
  # hubs = 'data/speedtrans/speedtrans__hubs.xlsx'
  # req = { 'key' => hubs }
  # ExcelTool::HubsOverwriter.new(params: req, _user: shipper).perform

  public_pricings = 'data/speedtrans/speedtrans__freight_rates.xlsx'
  req = { 'key' => public_pricings }
  ExcelTool::FreightRatesOverwriter.new(params: req, _user: shipper, generate: false).perform

  # # # # # #   # # # # # Overwrite public pricings from excel sheet

  # # puts "# Overwrite Local Charges From Sheet"
  # local_charges = 'data/speedtrans/speedtrans__local_charges.xlsx'
  # req = { 'key' => local_charges }
  # ExcelTool::OverwriteLocalCharges.new(params: req, user: shipper).perform
  # # #   # # # # # # Overwrite trucking data from excel sheet

  ### Insert schedules
  schedules = 'data/speedtrans/speedtrans__schedules.xlsx'
  req = { 'key' => schedules }
  ExcelTool::ScheduleOverwriter.new(params: req, mot: 'ocean', _user: shipper).perform

  #######
  puts 'Hamburg Port'
  hub = tenant.hubs.find_by_name('Hamburg Port')
  trucking = 'data/speedtrans/speedtrans__trucking_ltl__hamburg_port.xlsx'
  req = { 'key' => trucking }
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform

  # hubs = 'data/speedtrans/speedtrans__addons.xlsx'
  # req = { 'key' => hubs }
  # ExcelTool::OverwriteAddons.new(params: req, _user: shipper).perform
end
