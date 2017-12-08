include ExcelTools
include DynamoTools
# VehicleType.destroy_all
# TransportType.destroy_all
# Tenant.destroy_all
# User.destroy_all
# TruckingPricing.destroy_all
# Hub.destroy_all
# Pricing.destroy_all
# ServiceCharge.destroy_all
# Route.destroy_all
# Location.destroy_all
# UserLocation.destroy_all

# ['admin', 'shipper'].each do |role|
#   Role.find_or_create_by({name: role})
# end

# tenant = Tenant.create(
#   theme: {
#     colors: {
#       primary: "#0EAF50",
#       secondary: "#008ACB",
#       brightPrimary: "#06CA52", 
#       brightSecondary: "#0CA7F7"
#     },
#     logoLarge: "https://assets.itsmycargo.com/assets/images/logos/logo_black.png",
#     logoSmall: "https://assets.itsmycargo.com/assets/images/logos/logo_black_small.png"
#   },
#   addresses: {
#     main:"Torgny Segerstedtsgatan 80 426 77 Västra Frölunda"
#     },
#   phones:{ 
#     main:"+46 31-85 32 00",
#     support: "0173042031020"
#     },
#   emails: {
#     sales: "sales@greencarrier.com",
#     support: "support@greencarrier.com"
#   },
#   subdomain: "greencarrier",
#   name: "Greencarrier"
# )

# admin = tenant.users.new(
#   role: Role.find_by_name('admin'),

#   company_name: "Greencarrier",
#   first_name: "Admin",
#   last_name: "Admin",
#   phone: "123456789",

#   email: "admin@greencarrier.com",
#   password: "demo123456789",
#   password_confirmation: "demo123456789",

#   confirmed_at: DateTime.new(2017, 1, 20)
# )
# admin.skip_confirmation!
# admin.save!

# shipper = tenant.users.new(
#   role: Role.find_by_name('shipper'),

#   company_name: "Example Shipper Company",
#   first_name: "John",
#   last_name: "Smith",
#   phone: "123456789",

#   email: "demo@greencarrier.com",
#   password: "demo123456789",
#   password_confirmation: "demo123456789",

#   confirmed_at: DateTime.new(2017, 1, 20)
# )
# shipper.skip_confirmation!
# shipper.save!
# dummy_locations = [
#   {
#     street: "Kehrwieder",
#     street_number: "2",
#     zip_code: "20457",
#     city: "Hamburg",
#     country:"Germany"
#   },
#   {
#     street: "Carer del Cid",
#     street_number: "13",
#     zip_code: "08001",
#     city: "Barcelona",
#     country:"Spain"
#   },
#   {
#     street: "College Rd",
#     street_number: "1",
#     zip_code: "PO1 3LX",
#     city: "Portsmouth",
#     country:"United Kingdom"
#   },
#   {
#     street: "Tuna St",
#     street_number: "64",
#     zip_code: "90731",
#     city: "San Pedro",
#     country:"USA"
#   }
# ]
# dummy_contacts = [
#   {
#     company_name: "Another Example Shipper Company",
#     first_name: "Jane",
#     last_name: "Doe",
#     phone: "123456789",
#     email: "jane@doe.com"
#   },
#   {
#     company_name: "Yet Another Example Shipper Company",
#     first_name: "Javier",
#     last_name: "Garcia",
#     phone: "0034123456789",
#     email: "javi@shipping.com"
#   },
#   {
#     company_name: "Forwarder Company",
#     first_name: "Gertrude",
#     last_name: "Hummels",
#     phone: "0049123456789",
#     email: "gerti@fwd.com"
#   },
#   {
#     company_name: "Another Forwarder Company",
#     first_name: "Jerry",
#     last_name: "Lin",
#     phone: "001123456789",
#     email: "jerry@fwder2.com"
#   }
# ]

# vehicle_types = [
#   'ocean_default',
#   'rail_default',
#   'air_default',
#   'truck_default'
# ]
# cargo_types = [
#   'dry_goods',
#   'liquid_bulk',
#   'gas_bulk',
#   'any'
# ]
# load_types = [
#   'fcl_20f',
#   'fcl_40f',
#   'fcl_40f_hq',
#   'lcl'
# ]

# vehicle_types.each do |vt|
#   mot = vt.split('_')[0]
#   nvt = VehicleType.create(name:vt, mot: mot)
#   load_types.each do |lt|
#     cargo_types.each do |ct|
#       nvt.transport_types.create(mot: mot, cargo_class: lt, name: ct )
#     end
#   end
# end
# seed_init_table('pricings', 'price_id')
# seed_init_table('pathPricings', 'pathKey')
# hubs = File.open("./db/dummydata/1_hubs.xlsx")
# req = {"xlsx" => hubs}
# overwrite_hubs(req, shipper)
# shipper = User.find_by_email('demo@greencarrier.com')
# service_charges = File.open("./db/dummydata/2_service_charges.xlsx")
# req = {"xlsx" => service_charges}
# overwrite_service_charges(req, shipper)

# # public_pricings = File.open("./db/dummydata/3_PUBLIC_ocean_ptp_rates.xlsx")
# # req = {"xlsx" => public_pricings}
# # overwrite_main_carriage_rates(req, false, shipper)
 shipper = User.find_by_email('demo@greencarrier.com')
 public_pricings = File.open("./db/dummydata/3_PUBLIC_ocean_ptp_rates.xlsx")
 req = {"xlsx" => public_pricings}
 overwrite_dynamo_pricings(req, true, shipper)
 public_pricings = File.open("./db/dummydata/3_PUBLIC_ocean_ptp_rates.xlsx")
 req = {"xlsx" => public_pricings}
 overwrite_dynamo_pricings(req, false, shipper)


#   dummy_contacts.each_with_index do |c, i|
#     loc = Location.find_or_create_by(dummy_locations[i])
#     c[:location_id] = loc.id
#     shipper.contacts.create(c)
#   end
#   dummy_locations.each do |l|
#     loc = Location.find_or_create_by(l)
#     shipper.locations << loc
#   end
# trucking = File.open("./db/dummydata/5_trucking_rates_per_city.xlsx")
# req = {"xlsx" => trucking}
# overwrite_trucking_rates(req, shipper)

# trucking = File.open("./db/dummydata/shanghai_trucking.xlsx")
# req = {"xlsx" => trucking}
# overwrite_shanghai_trucking_rates(req, shipper)

# hubs = File.open("./db/dummydata/hub_images.xlsx")
# req = {"xlsx" => hubs}
# load_hub_images(req)

# schedules = File.open("./db/dummydata/6_vessel_schedules.xlsx")
# req = {"xlsx" => schedules}
# overwrite_vessel_schedules(req, shipper)
