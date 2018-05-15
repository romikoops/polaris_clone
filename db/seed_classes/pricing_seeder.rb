class PricingSeeder
	extend ExcelTools

	def self.exec(filter = {})
		Tenant.where(filter).each do |tenant|
			shipper = tenant.users.second
			tenant.itineraries.destroy_all
			tenant.stops.destroy_all
			tenant.trips.destroy_all
			tenant.layovers.destroy_all
		  tenant.hubs.destroy_all
		  # Location.where(location_type: 'nexus')
		  
		  MandatoryCharge.create_all!
		  
		  # # Overwrite hubs from excel sheet
		  puts "# Overwrite hubs from excel sheet"
		  hubs = File.open("#{Rails.root}/db/dummydata/1_hubs.xlsx")
		  req = {"xlsx" => hubs}
		  overwrite_hubs(req, shipper)

		  ### Overwrite dedicated pricings from excel sheet.
		  ### If dedicated == true, shipper.id is automatically inserted.

		  puts "# Overwrite freight rates (fcl and lcl) from excel sheet"
		  public_pricings = File.open("#{Rails.root}/db/dummydata/3_2_standard_sheet.xlsx")
		  req = {"xlsx" => public_pricings}
		  overwrite_freight_rates(req, shipper, true)
			
			# puts "# Overwrite Local Charges From Sheet"
			local_charges = File.open("#{Rails.root}/db/dummydata/2_local_charges.xlsx")
			req = {"xlsx" => local_charges}
			overwrite_local_charges(req, shipper)
		  # Overwrite trucking data from excel sheet

		  tenant.update_route_details # TODO: check if necessary
		end
	end
end
