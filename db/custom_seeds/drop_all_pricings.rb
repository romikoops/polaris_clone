include MongoTools

PRICING_TABLES = %w(
	customsFees
	pathPricing
	pricings
	routeOptions
	truckingHubs
	truckingTables
	userPricings
)

PRICING_TABLES.each { |table| drop_table table }
