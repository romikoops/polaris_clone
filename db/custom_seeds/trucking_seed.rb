puts "Creating trucking destinations for zipcodes..."
# zips = (10_000..98_999).map do |zip|
zips = (80928..98_999).map do |zip|
	{ zipcode: zip, country_code: 'SE' }
end
TruckingDestination.create(zips)

puts "Creating trucking destinations for Km..."
kms = (0..3_000).map do |km|
	{ distance: km }
end
TruckingDestination.create(kms)
