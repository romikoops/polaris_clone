include MongoTools

PRICING_TABLES = %w(
	customsFees
	hubRoutePricings
	pricings
	routeOptions
	truckingHubs
	truckingPricings
	truckingQueries
	localCharges
	userPricings
	itineraryPricings
	itineraryOptions
)

PRICING_TABLES.each { |table| drop_table table }
