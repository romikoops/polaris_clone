# frozen_string_literal: true

include ExcelTools

subdomains = %w(quotations)
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
  tenant.nexuses.destroy_all
  # tenant.users.shipper.where.not(id: shipper.id).destroy_all
  tenant.users.agent.destroy_all
  tenant.users.agency_manager.destroy_all
  tenant.agencies.destroy_all
  # # # #   # # # # #Overwrite hubs from excel sheet
  # puts '# Overwrite hubs from excel sheet'
  # hubs = "data/quotations/quotations__clients.xlsx"
  # req = { 'key' => hubs }
  # ExcelTool::ClientsOverwriter.new(params: req, _user: shipper).perform
  agents = 'data/quotations/quotations__agents.xlsx'
  req = { 'key' => agents }
  ExcelTool::AgentsOverwriter.new(params: req, _user: shipper).perform
  hubs = 'data/quotations/quotations__hubs.xlsx'
  req = { 'key' => hubs }
  ExcelTool::HubsOverwriter.new(params: req, _user: shipper).perform

  public_pricings = 'data/quotations/quotations__freight_rates.xlsx'
  req = { 'key' => public_pricings }
  ExcelTool::FreightRatesOverwriter.new(params: req, _user: shipper, generate: true).perform

  # # # # # #   # # # # # Overwrite public pricings from excel sheet

  puts '# Overwrite Local Charges From Sheet'
  local_charges = 'data/quotations/quotations__local_charges.xlsx'
  req = { 'key' => local_charges }
  ExcelTool::OverwriteLocalCharges.new(params: req, user: shipper).perform

  # # # #   # # # # # # Overwrite trucking data from excel sheet

  # puts 'Copenhagen Port'
  hub = tenant.hubs.find_by_name('Hamburg Port')
  trucking = 'data/quotations/quotations__trucking_ltl__hamburg_port.xlsx'
  req = { 'key' => trucking }
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
end
