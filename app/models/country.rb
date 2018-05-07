class Country < ApplicationRecord
	has_many :locations

	# Class Methods
	def self.geo_find_by_name(name)
		geocoder_results = Geocoder.search(country: name)
		return nil if geocoder_results.empty?
		
		code = geocoder_results.first.data["address_components"].first["short_name"]
		find_by(code: code)
	end
end
