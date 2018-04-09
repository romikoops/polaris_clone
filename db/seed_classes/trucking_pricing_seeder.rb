class TruckingPricingSeeder
	extend ExcelTools
	DIRECTIONS = %w(import export)

	def self.exec(filter = {})
		Tenant.where(filter).each do |tenant|
			shipper = tenant.users.where(role_id: 2).first 
			hub = tenant.hubs.find_by_name("Gothenburg Port")
			DIRECTIONS.each do |dir|
			  trucking = File.open("#{Rails.root}/db/dummydata/5_trucking_rates_per_city.xlsx")
			  req = {"xlsx" => trucking}
			  overwrite_zipcode_trucking_rates_by_hub(req, shipper, hub.id, 'GC Trucking', dir)
			end

			DIRECTIONS.each do |dir|
			  trucking = File.open("#{Rails.root}/db/dummydata/FTL_DISTANCE_SHEET.xlsx")
			  req = {"xlsx" => trucking}
			  overwrite_distance_trucking_rates_by_hub(req, shipper, hub.id, 'GC Trucking', dir, 'SE')
			end

			DIRECTIONS.each do |dir|
			  hub = tenant.hubs.find_by_name("Shanghai Port")
			  trucking = File.open("#{Rails.root}/db/dummydata/shanghai_trucking.xlsx")
			  req = {"xlsx" => trucking}
			  overwrite_city_trucking_rates_by_hub(req, shipper, hub.id, 'Globelink LTL', dir)
			end
		end
	end
end