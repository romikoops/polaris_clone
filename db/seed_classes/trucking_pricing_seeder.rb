class TruckingPricingSeeder
	extend ExcelTools
	DIRECTIONS = %w(import export)

	def self.exec(filter = {})
		Tenant.where(filter).each do |tenant|
			shipper = tenant.users.where(role_id: 2).first 
			hub = tenant.hubs.find_by_name("Shanghai Port")
			trucking = File.open("#{Rails.root}/db/dummydata/new_gc_trucking_shanghai_port.xlsx")
			req = {"xlsx" => trucking}
			overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)

			hub = tenant.hubs.find_by_name("Shanghai Port")
			trucking = File.open("#{Rails.root}/db/dummydata/new_gc_trucking_shanghai_port_ftl.xlsx")
			req = {"xlsx" => trucking}
			overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
			awesome_print "City rates done"
			
			hub = tenant.hubs.find_by_name("Gothenburg Port")
			trucking = File.open("#{Rails.root}/db/dummydata/new_gc_trucking_gothenburg_port.xlsx")
			req = {"xlsx" => trucking}
			overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
			awesome_print "Zip rates done"
			
			hub = tenant.hubs.find_by_name("Gothenburg Port")
			trucking = File.open("#{Rails.root}/db/dummydata/new_gc_trucking_gothenburg_port_ftl.xlsx")
			req = {"xlsx" => trucking}
			overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
			awesome_print "All rates done"

			hub = tenant.hubs.find_by_name("Stockholm Airport")
			trucking = File.open("#{Rails.root}/db/dummydata/new_gc_trucking_stockholm_airport.xlsx")
			req = {"xlsx" => trucking}
			overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
		end
	end
end
