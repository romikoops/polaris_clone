# frozen_string_literal: false

include ExcelTools
include ShippingTools
# subdomains = %w(demo greencarrier easyshipping hartrodt)
subdomains = %w(saco)
subdomains.each do |sub|
  tenant = Tenant.find_by_subdomain(sub)


  shipper = tenant.users.shipper.first
  # tenant.users.shipper.where.not(id: shipper.id).destroy_all
  # tenant.users.agent.destroy_all
  # tenant.users.agency_manager.destroy_all
  # tenant.agencies.destroy_all
  # shipment = shipper.shipments.where(status: 'requested').first
  # conf_shipment = shipper.shipments.where(status: 'confirmed').first
  # ShippingTools.tenant_notification_email(shipper, shipment)
  # ShippingTools.shipper_notification_email(shipper, shipment)
  # ShippingTools.shipper_confirmation_email(shipper, conf_shipment)
  tenant.itineraries.destroy_all
  tenant.local_charges.destroy_all
  tenant.customs_fees.destroy_all
# # #   # tenant.trucking_pricings.delete_all
  tenant.hubs.destroy_all
# # # # #   # # # # #Overwrite hubs from excel sheet
# #   # puts "# Overwrite hubs from excel sheet"

  hubs = File.open("#{Rails.root}/db/dummydata/saco/saco__hubs.xlsx")
  req = { 'xlsx' => hubs }
  ExcelTool::HubsOverwriter.new(params: req, _user: shipper).perform
  # Addon.destroy_all
  # agents = File.open("#{Rails.root}/db/dummydata/gateway/gateway__agents.xlsx")
  # req = { 'xlsx' => agents }
  # ExcelTool::AgentsOverwriter.new(params: req, _user: shipper).perform
# Translator::TranslationSetter.new(lang: 'en',section: 'landing', text: 'Introducing Online Freight Booking Services').perform

  

  path = "#{Rails.root}/db/dummydata/saco/fcl_export_loader.xlsx"
  imp_data = DataParser::Saco::SheetParserExport.new(path: path,
    _user: shipper,
    hub_type: 'ocean',
    load_type: 'container').perform
    
  imp_hubs = DataInserter::Saco::HubInserter.new(data: imp_data,
    tenant: tenant,
    _user: shipper,
    hub_type: 'ocean',
    direction: 'export').perform
    
  res = DataInserter::Saco::RateInserter.new(rates: imp_data,
    tenant: tenant,
    # counterpart_hub: 'Copenhagen Port',
    direction: 'export',
    cargo_class: 'container').perform

  # path = "#{Rails.root}/db/dummydata/easyshipping/pfc_export.xlsx"
  
  # ex_data = DataParser::PfcNordic::SheetParserExport.new(
  #   path: path,
  #   _user: shipper,
  #   counterpart_hub_name: 'Copenhagen Port',
  #   hub_type: 'ocean',
  #   input_language: 'de',
  #   cargo_class: 'lcl',
  #   load_type: 'cargo_item'
  #   ).perform
  
  # ex_hubs = DataInserter::PfcNordic::HubInserter.new(
  #   data: ex_data,
  #   tenant: tenant,
  #   counterpart_hub: 'Copenhagen Port',
  #   _user: shipper,
  #   hub_type: 'ocean',
  #   direction: 'export').perform

  # res = DataInserter::PfcNordic::RateInserter.new(
  #   rates: ex_data,
  #   tenant: tenant,
  #   counterpart_hub: 'Copenhagen Port',
  #   direction: 'export',
  #   cargo_class: 'lcl',
  #   input_language: 'de',).perform

  # local_charges = File.open("#{Rails.root}/db/dummydata/easyshipping/ez_seeder_local_charges.xlsx")
  # req = { 'xlsx' => local_charges }
  # ExcelTool::OverwriteLocalCharges.new(params: req,
  #   user: shipper).perform
  # # byebug
  
  # ex_lc_data = DataInserter::PfcNordic::LocalChargeInserter.new(data: ex_hubs,
  #   _user: shipper,
  #   counterpart_hub_name: 'Copenhagen Port',
  #   hub_type: 'ocean',
  #   direction: 'export'
  # ).perform
  

  # imp_lc_data = DataInserter::PfcNordic::LocalChargeInserter.new(data: imp_hubs,
  #   _user: shipper,
  #   counterpart_hub_name: 'Copenhagen Port',
  #   hub_type: 'ocean',
  #   direction: 'import'
  # ).perform
  
  
  #   # # #   # # # # puts "# Overwrite public pricings from excel sheet"

#   # public_pricings = File.open("#{Rails.root}/db/dummydata/NEW_hartrodt_rates.xlsx")
#   # req = {"xlsx" => public_pricings}
#   # overwrite_freight_rates(req, shipper, true)
#   # public_pricings = File.open("#{Rails.root}/db/dummydata/demo_freight_rates.xlsx")
#   # req = {"xlsx" => public_pricings}
#   # overwrite_freight_rates(req, shipper, true)
  public_pricings = File.open("#{Rails.root}/db/dummydata/saco/saco__freight_rates.xlsx")
  req = {"xlsx" => public_pricings}
  response = ExcelTool::FreightRatesOverwriter.new(params: req, _user: shipper, generate: false).perform
  # pp response
# # # # # #   # # # # # Overwrite public pricings from excel sheet

# #   # puts "# Overwrite Local Charges From Sheet"
# #     local_charges = File.open("#{Rails.root}/db/dummydata/gc_local_charges.xlsx")
# #     req = {"xlsx" => local_charges}
# #     overwrite_local_charges(req, shipper)
#   #  puts "# Overwrite Local Charges From Sheet"
#   local_charges = File.open("#{Rails.root}/db/dummydata/st_local_charges.xlsx")
#   req = {"xlsx" => local_charges}
#   overwrite_local_charges(req, shipper)


# #   # # # # # # Overwrite trucking data from excel sheet


      # hub = tenant.hubs.find_by_name("Shanghai Airport")
      # trucking = File.open("#{Rails.root}/db/dummydata/new_gc_trucking_shanghai_port.xlsx")
      # req = {"xlsx" => trucking}
      # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)

			# hub = tenant.hubs.find_by_name("Shanghai Port")
			# trucking = File.open("#{Rails.root}/db/dummydata/new_gc_trucking_shanghai_port.xlsx")
			# req = {"xlsx" => trucking}
			# overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)

			# hub = tenant.hubs.find_by_name("Shanghai Port")
			# trucking = File.open("#{Rails.root}/db/dummydata/new_gc_trucking_shanghai_port_ftl.xlsx")
			# req = {"xlsx" => trucking}
			# overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
			# awesome_print "City rates done"

			# hub = tenant.hubs.find_by_name("Gothenburg Port")
			# trucking = File.open("#{Rails.root}/db/dummydata/new_gc_trucking_gothenburg_port.xlsx")
			# req = {"xlsx" => trucking}
			# overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
			# awesome_print "Zip rates done"

			# hub = tenant.hubs.find_by_name("Gothenburg Port")
			# trucking = File.open("#{Rails.root}/db/dummydata/new_gc_trucking_gothenburg_port_ftl.xlsx")
			# req = {"xlsx" => trucking}
			# overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
			# awesome_print "All rates done"

			# hub = tenant.hubs.find_by_name("Stockholm Airport")
			# trucking = File.open("#{Rails.root}/db/dummydata/new_gc_trucking_stockholm_airport.xlsx")
			# req = {"xlsx" => trucking}
      # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)

      # hub = tenant.hubs.find_by_name("Malmo Airport")
			# trucking = File.open("#{Rails.root}/db/dummydata/new_gc_trucking_malmo_airport.xlsx")
			# req = {"xlsx" => trucking}
			# overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)



#   # awesome_print "City rates done"
  # hub = tenant.hubs.find_by_name("Gothenburg Port")
  # trucking = File.open("#{Rails.root}/db/dummydata/new_gc_trucking_gothenburg_ftl.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
#     hub = tenant.hubs.find_by_name("Gothenburg Port")
#   trucking = File.open("#{Rails.root}/db/dummydata/gc_trucking_gothenburg.xlsx")
#   req = {"xlsx" => trucking}
#   overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # hub = tenant.hubs.find_by_name("Hamburg Port")
  # trucking = File.open("#{Rails.root}/db/dummydata/st_trucking_hamburg_port.xlsx")
  # req = { 'xlsx' => trucking }
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  #   hub = tenant.hubs.find_by_name("Malmo Airport")
  #   trucking = File.open("#{Rails.root}/db/dummydata/gc_trucking_malmo_airport.xlsx")
  #   req = {"xlsx" => trucking}
  #   overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # # #   # awesome_print "Zip rates done"
  #   hub = tenant.hubs.find_by_name("Stockholm Airport")
  #   trucking = File.open("#{Rails.root}/db/dummydata/gc_trucking_stockholm_airport.xlsx")
  #   req = {"xlsx" => trucking}
  #   overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  #   # awesome_print "Zip rates done"

  #   hub = tenant.hubs.find_by_name("Shanghai Port")
  #   trucking = File.open("#{Rails.root}/db/dummydata/gc_trucking_china.xlsx")
  #   req = {"xlsx" => trucking}
  #   overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  #   awesome_print "All rates done"

  # hub = tenant.hubs.find_by_name("Shanghai Airport")
  # trucking = File.open("#{Rails.root}/db/dummydata/new_gc_trucking_shanghai_port.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # awesome_print "All rates done"

  # hub = tenant.hubs.find_by_name("Hamburg Port")
  # trucking = File.open("#{Rails.root}/db/dummydata/ht_trucking_hamburg_ftl.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # trucking = File.open("#{Rails.root}/db/dummydata/ht_trucking_hamburg_ltl.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)

  # hub = tenant.hubs.find_by_name("Frankfurt Airport")
  # trucking = File.open("#{Rails.root}/db/dummydata/ht_trucking_hamburg_ftl.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # trucking = File.open("#{Rails.root}/db/dummydata/ht_trucking_hamburg_ltl.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)

  #  hub = tenant.hubs.find_by_name("Hamburg Airport")
  # trucking = File.open("#{Rails.root}/db/dummydata/ht_trucking_hamburg_ftl.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # trucking = File.open("#{Rails.root}/db/dummydata/ht_trucking_hamburg_ltl.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)

  # hub = tenant.hubs.find_by_name("Antwerpen Port")
  # trucking = File.open("#{Rails.root}/db/dummydata/saco_trucking_antwerpen_ftl.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)

  # hub = tenant.hubs.find_by_name("Rotterdam Port")
  # trucking = File.open("#{Rails.root}/db/dummydata/ht_trucking_hamburg_ftl.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)

  # hub = tenant.hubs.find_by_name("Hamburg Port")
  # trucking = File.open("#{Rails.root}/db/dummydata/saco_trucking_hamburg_ftl.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # gothenburg_options_ltl = {
  #   tenant_id: 2,
  #   hub_id: 1,
  #   load_type: 'cargo_item'
  # }
  # hub = tenant.hubs.find_by_name("Gothenburg Port")
  # gothenburg_options_ftl = {
  #   tenant_id: tenant.id,
  #   hub_id: hub.id,
  #   load_type: 'container'
  # }
  # shanghai_options = {
  #   tenant_id: 2,
  #   hub_id: 3,
  #   load_type: 'cargo_item'
  # }
  # # gothenburg_ltl_url = write_trucking_to_sheet(gothenburg_options_ltl)
  # #  awesome_print gothenburg_ltl_url
  # gothenburg_ftl_url = write_trucking_to_sheet(gothenburg_options_ftl)
  # gothenburg_ftl_url = DocumentService::TruckingWriter.new(gothenburg_options_ftl).perform
  #  awesome_print gothenburg_ftl_url
  # shanghai_ltl_url = write_trucking_to_sheet(shanghai_options)
  #  awesome_print shanghai_ltl_url
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
  # itinerary = tenant.itineraries.find_by(name:'Gothenburg - Shanghai')
  # schedules = File.open("#{Rails.root}/db/dummydata/#{PATH TO FILE}")
  # params = {
    # "xlsx" => schedules,
    # "itinerary" => itinerary
  # }
  # ExcelTool::OverwriteSchedulesByItinerary.new(params: params, _user: shipper).perform

end
# user = Tenant.greencarrier.users.find_by_email('demo@greencarrier.com')
# gdpr_download(user.id)
