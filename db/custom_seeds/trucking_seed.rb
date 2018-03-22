zips = (10_000..98_999).map do |zip|
	{ zipcode: zip, country_code: 'SE' }
end

TruckingDestination.create(zips)