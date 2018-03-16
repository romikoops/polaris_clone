include ExcelTools
include MongoTools
['greencarrier'].each do |sub|
# Tenant.all.each do |tenant|
  tenant = Tenant.find_by_subdomain(sub)
  shipper = tenant.users.where(role_id: 2).first
 	# tenant.itineraries.destroy_all
	# 		tenant.stops.destroy_all
	# 		tenant.trips.destroy_all
	# 		tenant.layovers.destroy_all
	# 	  tenant.hubs.destroy_all
  # Overwrite hubs from excel sheet
  # puts "# Overwrite hubs from excel sheet"
  # hubs = File.open("#{Rails.root}/db/dummydata/1_hubs.xlsx")
  # req = {"xlsx" => hubs}
  # overwrite_hubs(req, shipper)

  # ### Overwrite dedicated pricings from excel sheet.
  ## If dedicated == true, shipper.id is automatically inserted.
  # puts "# Overwrite dedicated pricings from excel sheet."
  # public_pricings = File.open("#{Rails.root}/db/dummydata/new_public_ocean_ptp_rates.xlsx")
  # req = {"xlsx" => public_pricings}
  # overwrite_mongo_lcl_pricings(req, dedicated = true, shipper, true)

  # # # # # Overwrite public pricings from excel sheet
  # puts "# Overwrite public pricings from excel sheet"
  public_pricings = File.open("#{Rails.root}/db/dummydata/standard_sheet.xlsx")
  req = {"xlsx" => public_pricings}
  overwrite_freight_rates(req, shipper, false)
  Overwrite public pricings from excel sheet


  # # puts "# Overwrite MAERSK pricings from excel sheet"
  # # public_pricings = File.open("#{Rails.root}/db/dummydata/fcl_rates.xlsx")
  # # req = {"xlsx" => public_pricings}
  # # overwrite_mongo_maersk_fcl_pricings(req, dedicated = false, shipper)

  # puts "# Overwrite Local Charges From Sheet"
  local_charges = File.open("#{Rails.root}/db/dummydata/local_charges.xlsx")
  req = {"xlsx" => local_charges}
  overwrite_local_charges(req, shipper)


  # # # # # Overwrite trucking data from excel sheet
  # puts "# Overwrite trucking data from excel sheet"
  # ["import", "export"].each do |dir|
  #   trucking = File.open("#{Rails.root}/db/dummydata/5_trucking_rates_per_city.xlsx")
  #   req = {"xlsx" => trucking}
  #   overwrite_zipcode_weight_trucking_rates(req, shipper, dir)
  # end
  # ["import", "export"].each do |dir|
  #   trucking = File.open("#{Rails.root}/db/dummydata/shanghai_trucking.xlsx")
  #   req = {"xlsx" => trucking}
  #   overwrite_city_trucking_rates(req, shipper, dir)
  # end
  # tenant.update_route_details()
end
