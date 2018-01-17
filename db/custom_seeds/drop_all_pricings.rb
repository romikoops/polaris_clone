include MongoTools

PRICING_TABLES = %w(
	customsFees
	hubRoutePricings
	pricings
	routeOptions
	truckingHubs
	truckingTables
	userPricings
)

PRICING_TABLES.each { |table| drop_table table }
