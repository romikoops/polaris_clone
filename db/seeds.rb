include SeedTools

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
  theme: {},
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

# TruckingPricing.create!(price_per_km: 1.20)

hubs = File.open("./db/dummydata/hubs.xlsx")
req = {"xlsx" => hubs}
overwrite_hubs(req)

open_pricings = File.open("./db/dummydata/orates.xlsx")
req = {"xlsx" => open_pricings}
overwrite_main_carriage_rates(req, false)

ded_prices = File.open("./db/dummydata/drates.xlsx")
req = {"xlsx" => ded_prices}
overwrite_main_carriage_rates(req, true)

schedules = File.open("./db/dummydata/vs.xlsx")
req = {"xlsx" => schedules}
overwrite_vessel_schedules(req)

service_charges = File.open("./db/dummydata/local_charges.xlsx")
req = {"xlsx" => service_charges}
overwrite_service_charges(req)

trucking = File.open("./db/dummydata/trucking.xlsx")
req = {"xlsx" => trucking}
overwrite_trucking_rates(req)

# Location.create!([{
#     location_type: "hub_ocean",
#     hub_name: "Istanbul",
#     hub_operator: "Dp world Yarimca",
#     geocoded_address: "Mimar Sinan Mahallesi, Mehmet Akif Ersoy Cd. No:168, 41780 Körfez/Kocaeli, Türkei",
#     latitude: 40.7677387,
#     longitude: 29.75777579999999,
#     country: "Turkey",
#     hub_address_details: "Mimar Sinan Mahallesi, Mehmet Akif Ersoy Cd. No:168, 41780 Körfez/Kocaeli, Türkei",
#     hub_status: "active"
# },
# {
#     location_type: "hub_ocean",
#     hub_name: "Rijeka",
#     hub_operator: "Adriatic Gate Container Terminal",
#     geocoded_address: "Brajdica 14, 51000, Rijeka, Croatia",
#     latitude: 45.321415,
#     longitude: 14.457127,
#     country: "Croatia",
#     hub_address_details: "Setaliste A.K. Miosica n/n, P.O. Box 129, 51 000 Rijeka, CROATIA",
#     hub_status: "active"
# },
# {
#     location_type: "hub_train",
#     hub_name: "Ludwigshafen",
#     hub_operator: "KTL Kombi-Terminal Ludwigshafen GmbH",
#     geocoded_address: "KTL Kombi-Terminal Ludwigshafen GmbH, Am Hansenbusch 11, 67069 Ludwigshafen am Rhein",
#     latitude: 49.5383829,
#     longitude: 8.4127808,
#     country: "Germany",
#     hub_address_details: "KTL Kombi-Terminal Ludwigshafen GmbH, Am Hansenbusch 11, 67069 Ludwigshafen am Rhein",
#     hub_status: "active"
# },
# {
#     location_type: "hub_train",
#     hub_name: "Duisburg",
#     hub_operator: "Rhein- Ruhr Terminal Gesellschaft für Container- und Güterumschlag mbH",
#     latitude: 51.4280384,
#     longitude: 6.7370236,
#     geocoded_address: "Moerser Str. 66, 47059, Duisburg, Deutschland",
#     country: "Germany",
#     hub_address_details: "Rhein- Ruhr Terminal Gesellschaft für Container- und Güterumschlag mbH",
#     hub_status: "active"
# },
# {
#     location_type: "hub_train",
#     hub_name: "Rotterdam",
#     hub_operator: "",
#     geocoded_address: "Rotterdam",
#     latitude: 51.9244201,
#     longitude: 4.4777325,
#     country: "Netherlands",
#     hub_address_details: "Rotterdam",
#     hub_status: "active"
# },
# {
#     location_type: "hub_train",
#     hub_name: "Munich",
#     hub_operator: "DUSS München-Riem",
#     geocoded_address: "Hofbräuallee 11, 81829 München",
#     latitude: 48.14506,
#     longitude: 11.70659,
#     country: "Germany",
#     hub_address_details: "Hofbräuallee 11, 81829 München",
#     hub_status: "active"
# },
# {
#     location_type: "hub_train",
#     hub_name: "Hamburg",
#     hub_operator: "Hamburg Eurogate Intermodal GmbH",
#     geocoded_address: "Kurt-Eckelmann-Straße 1, 21126 Hamburg",
#     latitude: 53.52321999999999,
#     longitude: 9.924159999999999,
#     country: "Germany",
#     hub_address_details: "Kurt-Eckelmann-Straße 1, 21126 Hamburg",
#     hub_status: "active"
# }])

# # ---
# Route.create!([{
#     starthub: Location.where("location_type = ? AND geocoded_address = ?", "hub_ocean", "Istanbul").first,
#     endhub: Location.where("location_type = ? AND geocoded_address = ?", "hub_train", "Duisburg").first,
#     name: "Istanbul - Duisburg"
# }])

# RouteLocation.create!([{
#     route: Route.find_by_name("Istanbul - Duisburg"),
#     location: Location.where("location_type = ? AND hub_name = ?", "hub_ocean", "Istanbul").first,
#     position_in_hub_chain: 1
# },
# {
#     route: Route.find_by_name("Istanbul - Duisburg"),
#     location: Location.where("location_type = ? AND hub_name = ?", "hub_ocean", "Rijeka").first,
#     position_in_hub_chain: 2
# },
# {
#     route: Route.find_by_name("Istanbul - Duisburg"),
#     location: Location.where("location_type = ? AND hub_name = ?", "hub_train", "Ludwigshafen").first,
#     position_in_hub_chain: 3
# },
# {
#     route: Route.find_by_name("Istanbul - Duisburg"),
#     location: Location.where("location_type = ? AND hub_name = ?", "hub_train", "Duisburg").first,
#     position_in_hub_chain: 4
# }])
# # ---
# Route.create!([{
#     starthub: Location.where("location_type = ? AND geocoded_address = ?", "hub_ocean", "Istanbul").first,
#     endhub: Location.where("location_type = ? AND geocoded_address = ?", "hub_train", "Rotterdam").first,
#     name: "Istanbul - Rotterdam"
# }])
# RouteLocation.create!([{
#     route: Route.find_by_name("Istanbul - Rotterdam"),
#     location: Location.where("location_type = ? AND hub_name = ?", "hub_ocean", "Istanbul").first,
#     position_in_hub_chain: 1
# },
# {
#     route: Route.find_by_name("Istanbul - Rotterdam"),
#     location: Location.where("location_type = ? AND hub_name = ?", "hub_ocean", "Rijeka").first,
#     position_in_hub_chain: 2
# },
# {
#     route: Route.find_by_name("Istanbul - Rotterdam"),
#     location: Location.where("location_type = ? AND hub_name = ?", "hub_train", "Ludwigshafen").first,
#     position_in_hub_chain: 3
# },
# {
#     route: Route.find_by_name("Istanbul - Rotterdam"),
#     location: Location.where("location_type = ? AND hub_name = ?", "hub_train", "Rotterdam").first,
#     position_in_hub_chain: 4
# }])
# # ---
# Route.create!([{
#     starthub: Location.where("location_type = ? AND geocoded_address = ?", "hub_ocean", "Istanbul").first,
#     endhub: Location.where("location_type = ? AND geocoded_address = ?", "hub_train", "Hamburg").first,
#     name: "Istanbul - Hamburg"
# }])
# RouteLocation.create!([{
#     route: Route.find_by_name("Istanbul - Hamburg"),
#     location: Location.where("location_type = ? AND hub_name = ?", "hub_ocean", "Istanbul").first,
#     position_in_hub_chain: 1
# },
# {
#     route: Route.find_by_name("Istanbul - Hamburg"),
#     location: Location.where("location_type = ? AND hub_name = ?", "hub_ocean", "Rijeka").first,
#     position_in_hub_chain: 2
# },
# {
#     route: Route.find_by_name("Istanbul - Hamburg"),
#     location: Location.where("location_type = ? AND hub_name = ?", "hub_train", "Munich").first,
#     position_in_hub_chain: 3
# },
# {
#     route: Route.find_by_name("Istanbul - Hamburg"),
#     location: Location.where("location_type = ? AND hub_name = ?", "hub_train", "Hamburg").first,
#     position_in_hub_chain: 4
# }])
# # ---
# Route.create!([{
#     starthub: Location.where("location_type = ? AND geocoded_address = ?", "hub_ocean", "Istanbul").first,
#     endhub: Location.where("location_type = ? AND geocoded_address = ?", "hub_train", "Munich").first,
#     name: "Istanbul - Munich"
# }])
# RouteLocation.create!([{
#     route: Route.find_by_name("Istanbul - Munich"),
#     location: Location.where("location_type = ? AND hub_name = ?", "hub_ocean", "Istanbul").first,
#     position_in_hub_chain: 1
# },
# {
#     route: Route.find_by_name("Istanbul - Munich"),
#     location: Location.where("location_type = ? AND hub_name = ?", "hub_ocean", "Rijeka").first,
#     position_in_hub_chain: 2
# },
# {
#     route: Route.find_by_name("Istanbul - Munich"),
#     location: Location.where("location_type = ? AND hub_name = ?", "hub_train", "Munich").first,
#     position_in_hub_chain: 3
# }])
# # ---
# Route.create!([{
#     starthub: Location.where("location_type = ? AND geocoded_address = ?", "hub_ocean", "Istanbul").first,
#     endhub: Location.where("location_type = ? AND geocoded_address = ?", "hub_train", "Ludwigshafen").first,
#     name: "Istanbul - Ludwigshafen"
# }])
# RouteLocation.create!([{
#     route: Route.find_by_name("Istanbul - Ludwigshafen"),
#     location: Location.where("location_type = ? AND hub_name = ?", "hub_ocean", "Istanbul").first,
#     position_in_hub_chain: 1
# },
# {
#     route: Route.find_by_name("Istanbul - Ludwigshafen"),
#     location: Location.where("location_type = ? AND hub_name = ?", "hub_ocean", "Rijeka").first,
#     position_in_hub_chain: 2
# },
# {
#     route: Route.find_by_name("Istanbul - Ludwigshafen"),
#     location: Location.where("location_type = ? AND hub_name = ?", "hub_train", "Ludwigshafen").first,
#     position_in_hub_chain: 3
# }])

# OceanPricing.create!([{
#     starthub_name: "Istanbul",
#     endhub_name: "Rijeka",

#     size_class: "45'",
#     weight_class: "<= 5.0t",

#     price: 700
# }])

# TrainPricing.create!([{
#     starthub_name: "Rijeka",
#     endhub_name: "Ludwigshafen",

#     size_class: "45'",
#     weight_class: "<= 5.0t",

#     price: 800
# },
# {
#     starthub_name: "Ludwigshafen",
#     endhub_name: "Duisburg",

#     size_class: "45'",
#     weight_class: "<= 5.0t",

#     price: 450
# },
# {
#     starthub_name: "Ludwigshafen",
#     endhub_name: "Rotterdam",

#     size_class: "45'",
#     weight_class: "<= 5.0t",

#     price: 650
# },
# {
#     starthub_name: "Rijeka",
#     endhub_name: "Munich",

#     size_class: "45'",
#     weight_class: "<= 5.0t",

#     price: 600
# },
# {
#     starthub_name: "Munich",
#     endhub_name: "Hamburg",
    
#     size_class: "45'",
#     weight_class: "<= 5.0t",

#     price: 650
# }])

# Shipment.create!({
#     id: 3,
#     shipper_id: 2,
#     consignee_id: nil,
#     hs_code: nil,
#     cargo_notes: nil,
#     total_goods_value: nil,
#     planned_pickup_date: nil,
#     origin_id: 8,
#     destination_id: 9,
#     route_id: 3,
#     haulage: "1-truck;1-ocean;4-train;5-train;1-truck",
#     total_price: nil,
#     status: nil
# })