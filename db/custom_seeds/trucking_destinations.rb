# Utilizes activerecord-import's "import" method for bulk insertion.
# Please refer to https://github.com/zdennis/activerecord-import/wiki for more information.

puts "Creating trucking destinations for zipcodes..."
zips = (10_000..98_999).map do |zip|
	{ zipcode: zip, country_code: 'SE' }
end
TruckingDestination.import(zips)

puts "Creating trucking destinations for Km..."
kms = (0..3_000).map do |km|
	{ distance: km }
end
TruckingDestination.import(kms)
