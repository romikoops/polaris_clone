include ExcelTools
include MongoTools

# Tenant.all.each do |tenant|
  tenant = Tenant.find_by_subdomain("demo")
  shipper = tenant.users.second
  Stop.destroy_all
  Layover.destroy_all
  tenant.itineraries.destroy_all
  Trip.destroy_all
  # # Overwrite hubs from excel sheet
  # puts "# Overwrite hubs from excel sheet"
  # hubs = File.open("#{Rails.root}/db/dummydata/1_hubs.xlsx")
  # req = {"xlsx" => hubs}
  # overwrite_hubs(req, shipper)

  # # # Overwrite service charges from excel sheet
  # puts "# Overwrite service charges from excel sheet"
  # service_charges = File.open("#{Rails.root}/db/dummydata/2_service_charges.xlsx")
  # req = {"xlsx" => service_charges}
  # overwrite_service_charges(req, shipper)

  ## Overwrite dedicated pricings from excel sheet.
  #  If dedicated == true, shipper.id is automatically inserted.
  # puts "# Overwrite dedicated pricings from excel sheet."
  # public_pricings = File.open("#{Rails.root}/db/dummydata/new_public_ocean_ptp_rates.xlsx")
  # req = {"xlsx" => public_pricings}
  # overwrite_mongo_lcl_pricings(req, dedicated = true, shipper)

  # # Overwrite public pricings from excel sheet
  # puts "# Overwrite public pricings from excel sheet"
  # public_pricings = File.open("#{Rails.root}/db/dummydata/new_public_ocean_ptp_rates.xlsx")
  # req = {"xlsx" => public_pricings}
  # overwrite_mongo_lcl_pricings(req, dedicated = false, shipper)

  puts "# Overwrite MAERSK pricings from excel sheet"
  public_pricings = File.open("#{Rails.root}/db/dummydata/mini_MAERSK_FCL.xlsx")
  req = {"xlsx" => public_pricings}
  overwrite_mongo_maersk_fcl_pricings(req, dedicated = false, shipper)

  # OLD, SQL DB method (!): Overwrite public pricings from excel sheet
  # public_pricings = File.open("#{Rails.root}/db/dummydata/3_PUBLIC_ocean_ptp_rates.xlsx")
  # req = {"xlsx" => public_pricings}
  # overwrite_main_carriage_rates(req, false, shipper)
  # shipper = User.find_by_email('demo@greencarrier.com')

  # Overwrite trucking data from excel sheet
  # puts "# Overwrite trucking data from excel sheet"
  # trucking = File.open("#{Rails.root}/db/dummydata/5_trucking_rates_per_city.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_trucking_rates(req, shipper)

  # trucking = File.open("#{Rails.root}/db/dummydata/shanghai_trucking.xlsx")
  # req = {"xlsx" => trucking}
  # overwrite_city_trucking_rates(req, shipper)

  tenant.update_route_details()
# end
