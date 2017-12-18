include ExcelTools
include MongoTools

# Drop all tables
Vehicle.destroy_all
TransportCategory.destroy_all
Tenant.destroy_all
User.destroy_all
TruckingPricing.destroy_all
Hub.destroy_all
Pricing.destroy_all
ServiceCharge.destroy_all
Route.destroy_all
Location.destroy_all
UserLocation.destroy_all

# Create user roles
['admin', 'shipper'].each do |role|
  Role.find_or_create_by({name: role})
end

# Define data for two tenants
tenant_data = [
  {
    theme: {
      colors: {
        primary: "#0EAF50",
        secondary: "#008ACB",
        brightPrimary: "#06CA52",
        brightSecondary: "#0CA7F7"
      },
      logoLarge: "https://assets.itsmycargo.com/assets/images/logos/logo_black.png",
      logoSmall: "https://assets.itsmycargo.com/assets/images/logos/logo_black_small.png"
    },
    addresses: {
      main:"Torgny Segerstedtsgatan 80 426 77 Västra Frölunda"
    },
    phones:{
      main:"+46 31-85 32 00",
      support: "0173042031020"
    },
    emails: {
      sales: "sales@greencarrier.com",
      support: "support@greencarrier.com"
    },
    subdomain: "greencarrier",
    name: "Greencarrier"
  },
  {
    theme: {
      colors: {
        primary: "#0D5BA9",
        secondary: "#23802A",
        brightPrimary: "#2491FD",
        brightSecondary: "#25ED36"
      },
      logoLarge: 'https://assets.itsmycargo.com/assets/logos/logo_box.png',
      logoSmall: 'https://assets.itsmycargo.com/assets/logos/logo_box.png'
    },
    addresses: {
      main:"Brooktorkai 7, Hamburg, 20457,Germany"
    },
    phones:{
      main:"+46 31-85 32 00",
      support: "0173042031020"
    },
    emails: {
      sales: "sales@demo.com",
      support: "support@demo.com"
    },
    subdomain: "demo",
    name: "Demo"
  }
]

tenant_data.each do |ten|
  tenant = Tenant.create(
    ten
  )

  # Create admin
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
  admin.skip_confirmation!
  admin.save!

  # Create shipper
  shipper = tenant.users.new(
    role: Role.find_by_name('shipper'),

    company_name: "Example Shipper Company",
    first_name: "John",
    last_name: "Smith",
    phone: "123456789",

    email: "demo@#{tenant.subdomain}.com",
    password: "demo123456789",
    password_confirmation: "demo123456789",

    confirmed_at: DateTime.new(2017, 1, 20)
  )
  shipper.skip_confirmation!
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
    loc = Location.find_or_create_by(l)
    shipper.locations << loc
  end

  # Create dummy contacts for shipper address book
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

  dummy_contacts.each_with_index do |contact, i|
    loc = Location.find_or_create_by(dummy_locations[i])
    contact[:location_id] = loc.id
    shipper.contacts.create(contact)
  end

  # Create vehicle types
  vehicle_types = [
    'ocean_default',
    'rail_default',
    'air_default',
    'truck_default'
  ]
  cargo_types = [
    'dry_goods',
    'liquid_bulk',
    'gas_bulk',
    'any'
  ]
  load_types = [
    'fcl_20f',
    'fcl_40f',
    'fcl_40f_hq',
    'lcl'
  ]

  vehicle_types.each do |vt|
    mot = vt.split('_')[0]
    vehicle = Vehicle.create(name: vt, mode_of_transport: mot)
    tenant.tenant_vehicles.create(name: vt, mode_of_transport: mot, vehicle_id: vehicle.id)

    load_types.each do |lt|
      cargo_types.each do |ct|
        vehicle.transport_categories.create(mode_of_transport: mot, cargo_class: lt, name: ct )
      end
    end
  end

  # Overwrite hubs from excel sheet
  hubs = File.open("./db/dummydata/1_hubs.xlsx")
  req = {"xlsx" => hubs}
  overwrite_hubs(req, shipper)

  # Overwrite service charges from excel sheet
  service_charges = File.open("./db/dummydata/2_service_charges.xlsx")
  req = {"xlsx" => service_charges}
  overwrite_service_charges(req, shipper)

  # Overwrite dedicated pricings from excel sheet.
  #   If dedicated == true, shipper.id is automatically inserted.
  public_pricings = File.open("./db/dummydata/3_PUBLIC_ocean_ptp_rates.xlsx")
  req = {"xlsx" => public_pricings}
  overwrite_mongo_pricings(req, true, shipper)

  # Overwrite public pricings from excel sheet
  public_pricings = File.open("./db/dummydata/3_PUBLIC_ocean_ptp_rates.xlsx")
  req = {"xlsx" => public_pricings}
  overwrite_mongo_pricings(req, false, shipper)

  # OLD, SQL DB method (!): Overwrite public pricings from excel sheet
  # public_pricings = File.open("./db/dummydata/3_PUBLIC_ocean_ptp_rates.xlsx")
  # req = {"xlsx" => public_pricings}
  # overwrite_main_carriage_rates(req, false, shipper)
  # shipper = User.find_by_email('demo@greencarrier.com')

  # Overwrite trucking data from excel sheet
  trucking = File.open("./db/dummydata/5_trucking_rates_per_city.xlsx")
  req = {"xlsx" => trucking}
  overwrite_trucking_rates(req, shipper)

  trucking = File.open("./db/dummydata/shanghai_trucking.xlsx")
  req = {"xlsx" => trucking}
  overwrite_shanghai_trucking_rates(req, shipper)
end
