include ExcelTools

Tenant.destroy_all
User.destroy_all
TruckingPricing.destroy_all
Hub.destroy_all
Schedule.destroy_all
Pricing.destroy_all
ServiceCharge.destroy_all
Route.destroy_all
Location.destroy_all
UserLocation.destroy_all

['admin', 'shipper'].each do |role|
  Role.find_or_create_by({name: role})
end

tenant = Tenant.create(
  theme: {
    colors: {
      primary: "#0EAF50",
      secondary: "#008ACB",
      brightPrimary: "#06CA52", 
      brightSecondary: "#0CA7F7"
    },
    logoLarge: "https://s3.eu-central-1.amazonaws.com/imcdev/assets/images/logos/logo_black.png",
    logoSmall: "https://s3.eu-central-1.amazonaws.com/imcdev/assets/images/logos/logo_black_small.png"
  },
  address: "Torgny Segerstedtsgatan 80 426 77 Västra Frölunda",
  phone: "+46 31-85 32 00",
  emails: {
  },
  subdomain: "greencarrier"
)

admin = tenant.users.new(
  role: Role.find_by_name('admin'),

  company_name: "Greencarrier",
  first_name: "Admin",
  last_name: "Admin",
  phone: "123456789",

  email: "admin@greencarrier.com",
  password: "demo123456789",
  password_confirmation: "demo123456789",

  confirmed_at: DateTime.new(2017, 1, 20)
)
admin.skip_confirmation!
admin.save!

shipper = tenant.users.new(
  role: Role.find_by_name('shipper'),

  company_name: "Example Shipper Company",
  first_name: "John",
  last_name: "Smith",
  phone: "123456789",

  email: "demo@greencarrier.com",
  password: "demo123456789",
  password_confirmation: "demo123456789",

  confirmed_at: DateTime.new(2017, 1, 20)
)
shipper.skip_confirmation!
shipper.save!
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
dummy_contacts = [
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


hubs = File.open("./db/dummydata/1_hubs.xlsx")
req = {"xlsx" => hubs}
overwrite_hubs(req, shipper)

service_charges = File.open("./db/dummydata/2_service_charges.xlsx")
req = {"xlsx" => service_charges}
overwrite_service_charges(req, shipper)

public_pricings = File.open("./db/dummydata/3_PUBLIC_ocean_ptp_rates.xlsx")
req = {"xlsx" => public_pricings}
overwrite_main_carriage_rates(req, false, shipper)

users = User.where(email: 'demo@greencarrier.com')
users.each do |tmpuser|
  dummy_contacts.each_with_index do |c, i|
    loc = Location.find_or_create_by(dummy_locations[i])
    c[:location_id] = loc.id
    tmpuser.contacts.create(c)
  end


  client_prices = File.open("./db/dummydata/3_PUBLIC_ocean_ptp_rates.xlsx")
  req = {"xlsx" => client_prices}
  overwrite_main_carriage_rates(req, true, tmpuser)
end
trucking = File.open("./db/dummydata/5_trucking_rates_per_city.xlsx")
req = {"xlsx" => trucking}
overwrite_trucking_rates(req, shipper)

trucking = File.open("./db/dummydata/shanghai_trucking.xlsx")
req = {"xlsx" => trucking}
overwrite_shanghai_trucking_rates(req, shipper)

# hubs = File.open("./db/dummydata/hub_images.xlsx")
# req = {"xlsx" => hubs}
# load_hub_images(req)

# schedules = File.open("./db/dummydata/6_vessel_schedules.xlsx")
# req = {"xlsx" => schedules}
# overwrite_vessel_schedules(req, shipper)
