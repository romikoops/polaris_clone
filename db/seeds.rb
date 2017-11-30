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

hubs = File.open("./db/dummydata/1_hubs.xlsx")
req = {"xlsx" => hubs}
overwrite_hubs(req, shipper)

service_charges = File.open("./db/dummydata/2_service_charges.xlsx")
req = {"xlsx" => service_charges}
overwrite_service_charges(req, shipper)

public_pricings = File.open("./db/dummydata/3_PUBLIC_ocean_ptp_rates.xlsx")
req = {"xlsx" => public_pricings}
overwrite_main_carriage_rates(req, false, shipper)

client_prices = File.open("./db/dummydata/4_CLIENT_ocean_ptp_rates.xlsx")
req = {"xlsx" => client_prices}
overwrite_main_carriage_rates(req, true, shipper)

trucking = File.open("./db/dummydata/5_trucking_rates_per_city.xlsx")
req = {"xlsx" => trucking}
overwrite_trucking_rates(req, shipper)

trucking = File.open("./db/dummydata/shanghai_trucking.xlsx")
req = {"xlsx" => trucking}
overwrite_shanghai_trucking_rates(req, shipper)

hubs = File.open("./db/dummydata/hub_images.xlsx")
req = {"xlsx" => hubs}
load_hub_images(req)

# schedules = File.open("./db/dummydata/6_vessel_schedules.xlsx")
# req = {"xlsx" => schedules}
# overwrite_vessel_schedules(req, shipper)
