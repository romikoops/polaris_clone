# frozen_string_literal: true

include ExcelTools
include DocumentTools
include MongoTools
# subdomains = %w(demo greencarrier easyshipping hartrodt)
subdomains = %w[speedtrans speedtrans-sandbox]
subdomains.each do |sub|
  # # Tenant.all.each do |tenant|
  tenant = Tenant.find_by_subdomain(sub)

  shipper = tenant.users.shipper.first
  # tenant.itineraries.destroy_all
  # tenant.local_charges.destroy_all
  # tenant.customs_fees.destroy_all
  # tenant.trucking_pricings.delete_all
  # tenant.hubs.destroy_all
  # # #   # # # # #Overwrite hubs from excel sheet
  puts '# Overwrite hubs from excel sheet'
  hubs = File.open("#{Rails.root}/db/dummydata/st_hubs.xlsx")
  req = { 'xlsx' => hubs }
  overwrite_hubs(req, shipper)

  public_pricings = File.open("#{Rails.root}/db/dummydata/st_freight_rates.xlsx")
  req = { 'xlsx' => public_pricings }
  overwrite_freight_rates(req, shipper, true)

  # # # # #   # # # # # Overwrite public pricings from excel sheet

  # puts "# Overwrite Local Charges From Sheet"
  local_charges = File.open("#{Rails.root}/db/dummydata/st_local_charges.xlsx")
  req = { 'xlsx' => local_charges }
  overwrite_local_charges(req, shipper)

  # #   # # # # # # Overwrite trucking data from excel sheet

  puts 'Hamburg Port'
  hub = tenant.hubs.find_by_name('Hamburg Port')
  trucking = File.open("#{Rails.root}/db/dummydata/st_trucking_hamburg_port.xlsx")
  req = { 'xlsx' => trucking }
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform

  # admin_sea = tenant.users.new(
  #   role: Role.find_by_name('admin'),

  #   company_name: tenant.name,
  #   first_name: "Ocean Freight",
  #   last_name: "Admin",
  #   phone: "+46 31-85 32 00",

  #   email: "imc.sea.se@greencarrier.se",
  #   password: "oceanfreightadmin",
  #   password_confirmation: "oceanfreightadmin",

  #   confirmed_at: DateTime.new(2017, 1, 20)
  # )
  # # admin.skip_confirmation!
  # admin_sea.save!
  # admin_air = tenant.users.new(
  #   role: Role.find_by_name('admin'),

  #   company_name: tenant.name,
  #   first_name: "Air Freight",
  #   last_name: "Admin",
  #   phone: "+46 31-85 32 00",

  #   email: "imc.air.se@greencarrier.se",
  #   password: "airfreightadmin",
  #   password_confirmation: "airfreightadmin",

  #   confirmed_at: DateTime.new(2017, 1, 20)
  # )
  # # admin.skip_confirmation!
  # admin_air.save!
end
