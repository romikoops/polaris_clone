# frozen_string_literal: true

include ExcelTools
include MongoTools
# subdomains = %w(demo greencarrier easyshipping hartrodt)
subdomains = %w[greencarrier greencarrier-sandbox]
subdomains.each do |sub|
  # # Tenant.all.each do |tenant|
  tenant = Tenant.find_by_subdomain(sub)

  shipper = tenant.users.shipper.first
  # tenant.itineraries.destroy_all
  # tenant.local_charges.destroy_all
  # tenant.customs_fees.destroy_all
  # tenant.trucking_pricings.delete_all
  # HubTrucking.where(hub: tenant.hubs).delete_all
  # tenant.hubs.destroy_all
  # tenant.nexuses.destroy_all
  # # # # # #   # # # # #Overwrite hubs from excel sheet
  # # # # # puts '# Overwrite hubs from excel sheet'
  # hubs = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__hubs.xlsx")
  # req = { 'xlsx' => hubs }
  # ExcelTool::HubsOverwriter.new(params: req, _user: shipper).perform

  public_pricings = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__freight_rates.xlsx")
  req = { 'xlsx' => public_pricings }
  ExcelTool::FreightRatesOverwriter.new(params: req, _user: shipper, generate: true).perform
  # # # # # # # #   # # # # # Overwrite public pricings from excel sheet

  # # # # # puts "# Overwrite Local Charges From Sheet"
  # local_charges = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__local_charges.xlsx")
  # req = { 'xlsx' => local_charges }
  # ExcelTool::OverwriteLocalCharges.new(params: req, user: shipper).perform

  # # #   # # # # # # Overwrite trucking data from excel sheet

  # puts 'Shanghai Airport'
  # hub = tenant.hubs.find_by_name('Shanghai Airport')
  # trucking = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__trucking_ltl__shanghai_port.xlsx")
  # req = { 'xlsx' => trucking }
  # ExcelTool::OverrideTruckingRateByHub.new(
  #   params: req, _user: shipper, hub_id: hub.id
  # ).perform
  # puts 'Shanghai Port'
  # hub = tenant.hubs.find_by_name('Shanghai Port')
  # trucking = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__trucking_ltl__shanghai_port.xlsx")
  # req = { 'xlsx' => trucking }
  # ExcelTool::OverrideTruckingRateByHub.new(
  #         params: req, _user: shipper, hub_id: hub.id
  #       ).perform
  # puts 'Shanghai Airport ftl'
  # hub = tenant.hubs.find_by_name('Shanghai Port')
  # trucking = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__trucking_ftl__shanghai_port.xlsx")
  # req = { 'xlsx' => trucking }
  # ExcelTool::OverrideTruckingRateByHub.new(
  #         params: req, _user: shipper, hub_id: hub.id
  #       ).perform
  # awesome_print 'City rates done'
  # puts 'Gothenburg Port'
  # hub = tenant.hubs.find_by_name('Gothenburg Port')
  # trucking = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__trucking_ltl__gothenburg_port.xlsx")
  # req = { 'xlsx' => trucking }
  # ExcelTool::OverrideTruckingRateByHub.new(
  #         params: req, _user: shipper, hub_id: hub.id
  #       ).perform
  # puts 'Gothenburg Airport'
  # hub = tenant.hubs.find_by_name('Gothenburg Airport')
  # trucking = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__trucking_ltl__gothenburg_airport.xlsx")
  # req = { 'xlsx' => trucking }
  # ExcelTool::OverrideTruckingRateByHub.new(
  #         params: req, _user: shipper, hub_id: hub.id
  #       ).perform
  # awesome_print 'Zip rates done'
  # puts 'Gothenburg Port ftl'
  # hub = tenant.hubs.find_by_name('Gothenburg Port')
  # trucking = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__trucking_ftl__gothenburg_port.xlsx")
  # req = { 'xlsx' => trucking }
  # ExcelTool::OverrideTruckingRateByHub.new(
  #         params: req, _user: shipper, hub_id: hub.id
  #       ).perform
  # awesome_print 'All rates done'
  # puts 'Stockholm Airport'
  # hub = tenant.hubs.find_by_name('Stockholm Airport')
  # trucking = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__trucking_ltl__stockholm_airport.xlsx")
  # req = { 'xlsx' => trucking }
  # ExcelTool::OverrideTruckingRateByHub.new(
  #         params: req, _user: shipper, hub_id: hub.id
  #       ).perform
  # puts 'Malmo Airport'
  # hub = tenant.hubs.find_by_name('Malmo Airport')
  # trucking = File.open("#{Rails.root}/db/dummydata/greencarrier/greencarrier__trucking_ltl__malmo_airport.xlsx")
  # req = { 'xlsx' => trucking }
  # ExcelTool::OverrideTruckingRateByHub.new(
  #         params: req, _user: shipper, hub_id: hub.id
  #       ).perform

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
