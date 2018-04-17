include ExcelTools
include DocumentTools
include MongoTools
['hartrodt'].each do |sub|
# # Tenant.all.each do |tenant|
  tenant = Tenant.find_by_subdomain(sub)
  admin = tenant.users.new(
    role: Role.find_by_name('admin'),

    company_name: tenant.name,
    first_name: "Admin",
    last_name: "Admin",
    phone: "123456789",

    email: "admin@#{tenant.subdomain}.com",
    password: "demo123456789",
    password_confirmation: "demo123456789",

    confirmed_at: DateTime.new(2017, 1, 20)
  )
  # admin.skip_confirmation!
  admin.save!
  sub_admin = tenant.users.new(
    role: Role.find_by_name('sub_admin'),

    company_name: tenant.name,
    first_name: "Sub",
    last_name: "Admin",
    phone: "123456789",

    email: "subadmin@#{tenant.subdomain}.com",
    password: "demo123456789",
    password_confirmation: "demo123456789",

    confirmed_at: DateTime.new(2017, 1, 20)
  )
  sub_admin.save!
  tld = tenant.web && tenant.web["tld"] ? tenant.web["tld"] : 'com'
  shipper = tenant.users.new(
    role: Role.find_by_name('shipper'),

    company_name: "Example Shipper Company",
    first_name: "John",
    last_name: "Smith",
    phone: "123456789",

    email: "demo@#{tenant.subdomain}.#{tld}",
    password: "demo123456789",
    password_confirmation: "demo123456789",

    confirmed_at: DateTime.new(2017, 1, 20)
  )
  # shipper.skip_confirmation!
  shipper.save!
  # Create dummy locations for shipper
  dummy_locations = [
    {
      street: "Kehrwieder",
      street_number: "2",
      zip_code: "20457",
      city: "Hamburg",
      country:"Germany"
    },
    {
      street: "Carer del Cid",
      street_number: "13",
      zip_code: "08001",
      city: "Barcelona",
      country:"Spain"
    },
    {
      street: "College Rd",
      street_number: "1",
      zip_code: "PO1 3LX",
      city: "Portsmouth",
      country:"United Kingdom"
    },
    {
      street: "Tuna St",
      street_number: "64",
      zip_code: "90731",
      city: "San Pedro",
      country:"USA"
    }
  ]

  dummy_locations.each do |l|
    loc = Location.create_and_geocode(l)
    shipper.locations << loc
  end

  # Create dummy contacts for shipper address book
  dummy_contacts = [
    {
      company_name: "Example Shipper Company",
      first_name: "John",
      last_name: "Smith",
      phone: "123456789",
      email: "demo@#{tenant.subdomain}.com",
    },
    {
      company_name: "Another Example Shipper Company",
      first_name: "Jane",
      last_name: "Doe",
      phone: "123456789",
      email: "jane@doe.com"
    },
    {
      company_name: "Yet Another Example Shipper Company",
      first_name: "Javier",
      last_name: "Garcia",
      phone: "0034123456789",
      email: "javi@shipping.com"
    },
    {
      company_name: "Forwarder Company",
      first_name: "Gertrude",
      last_name: "Hummels",
      phone: "0049123456789",
      email: "gerti@fwd.com"
    },
    {
      company_name: "Another Forwarder Company",
      first_name: "Jerry",
      last_name: "Lin",
      phone: "001123456789",
      email: "jerry@fwder2.com"
    }
  ]

  dummy_contacts.each_with_index do |contact, i|
    loc = Location.find_or_create_by(dummy_locations[i])
    contact[:location_id] = loc.id
    shipper.contacts.create(contact)
  end
  shipper = tenant.users.where(role_id: 2).first
#  	tenant.itineraries.destroy_all
# 			tenant.stops.destroy_all
# 			tenant.trips.destroy_all
# 			tenant.layovers.destroy_all
# 		  tenant.hubs.destroy_all
#   #Overwrite hubs from excel sheet
  puts "# Overwrite hubs from excel sheet"
  hubs = File.open("#{Rails.root}/db/dummydata/1_hubs.xlsx")
  req = {"xlsx" => hubs}
  overwrite_hubs(req, shipper)

#   # ### Overwrite dedicated pricings from excel sheet.
#   ## If dedicated == true, shipper.id is automatically inserted.
#   # puts "# Overwrite dedicated pricings from excel sheet."
#   # public_pricings = File.open("#{Rails.root}/db/dummydata/new_public_ocean_ptp_rates.xlsx")
#   # req = {"xlsx" => public_pricings}
#   # overwrite_mongo_lcl_pricings(req, dedicated = true, shipper, true)

#   # # # # # Overwrite public pricings from excel sheet
  # puts "# Overwrite public pricings from excel sheet"

  public_pricings = File.open("#{Rails.root}/db/dummydata/standard_sheet.xlsx")
  req = {"xlsx" => public_pricings}
  overwrite_freight_rates(req, shipper, true)

  # # # Overwrite public pricings from excel sheet


  # # puts "# Overwrite MAERSK pricings from excel sheet"
  # # public_pricings = File.open("#{Rails.root}/db/dummydata/fcl_rates.xlsx")
  # # req = {"xlsx" => public_pricings}
  # # overwrite_mongo_maersk_fcl_pricings(req, dedicated = false, shipper)

  puts "# Overwrite Local Charges From Sheet"
  local_charges = File.open("#{Rails.root}/db/dummydata/local_charges.xlsx")
  req = {"xlsx" => local_charges}
  overwrite_local_charges(req, shipper)


  # # # # # Overwrite trucking data from excel sheet

  # puts "# Overwrite trucking data from excel sheet" (params, user = current_user, hub_id, courier_name, direction, country_code)
  # hub = tenant.hubs.find_by_name("Gothenburg Port")
  # ["import", "export"].each do |dir|
  #   trucking = File.open("#{Rails.root}/db/dummydata/FTL_DISTANCE_SHEET.xlsx")
  #   req = {"xlsx" => trucking}
  #   overwrite_distance_trucking_rates_by_hub(req, shipper, hub.id, 'GC Trucking', dir, "SE")
  # end
  # ["import", "export"].each do |dir|
  #   hub = tenant.hubs.find_by_name("Shanghai Port")
  #   trucking = File.open("#{Rails.root}/db/dummydata/shanghai_trucking.xlsx")
  #   req = {"xlsx" => trucking}
  #   overwrite_city_trucking_rates_by_hub(req, shipper,  hub.id, 'Globelink LTL', dir)
  # end
  # hub = tenant.hubs.find_by_name("Stockholm Airport")
  # ["import", "export"].each do |dir|
  #   trucking = File.open("#{Rails.root}/db/dummydata/Stockholm_Trucking_Rates.xlsx")
  #   req = {"xlsx" => trucking}
  #   # split_zip_code_sections(req, shipper, hub.id, 'GC Trucking', dir) 
  #   overwrite_zipcode_trucking_rates_by_hub(req, shipper, hub.id, 'GC Trucking', dir)
  # end

  # hub = tenant.hubs.find_by_name("Shanghai Port")
  # # ["import"].each do |dir|
  #   # trucking = File.open("#{Rails.root}/db/dummydata/5_trucking_rates_per_city.xlsx")
  #   trucking = File.open("#{Rails.root}/db/dummydata/gc_trucking_china.xlsx")
  #   req = {"xlsx" => trucking}
  # #   # split_zip_code_sections(req, shipper, hub.id, 'GC Trucking', dir) 
  # #   overwrite_zipcode_trucking_rates_by_hub(req, shipper, hub.id, 'GC Trucking', dir)
  #   overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # end
 
  hub = tenant.hubs.find_by_name("Shanghai Port")
  trucking = File.open("#{Rails.root}/db/dummydata/gc_trucking_china.xlsx")
  req = {"xlsx" => trucking}
  overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  awesome_print "City rates done"
  hub = tenant.hubs.find_by_name("Gothenburg Port")
  trucking = File.open("#{Rails.root}/db/dummydata/gc_trucking_gothenburg.xlsx")
  req = {"xlsx" => trucking}
  overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  awesome_print "Zip rates done"
  
  hub = tenant.hubs.find_by_name("Gothenburg Port")
  trucking = File.open("#{Rails.root}/db/dummydata/gc_trucking_gothenburg_ftl.xlsx")
  req = {"xlsx" => trucking}
  overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  awesome_print "All rates done"

  # hub = tenant.hubs.find_by_name("Copenhagen Port")
  # trucking = File.open("#{Rails.root}/db/dummydata/es_trucking.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)

  # hub = tenant.hubs.find_by_name("Shenzhen Port")
  # trucking = File.open("#{Rails.root}/db/dummydata/es_trucking.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)

  tenant.update_route_details()
end
