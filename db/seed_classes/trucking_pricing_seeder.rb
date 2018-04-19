class TruckingPricingSeeder
	extend ExcelTools
	DIRECTIONS = %w(import export)

	def self.exec(filter = {})
		Tenant.where(filter).each do |tenant|
			shipper = tenant.users.where(role_id: 2).first 
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
		end
	end
end