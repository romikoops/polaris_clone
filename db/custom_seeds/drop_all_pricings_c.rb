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

puts " "
PRICING_TABLES.each_with_index { |table, i| puts "#{i + 1} - #{table}" }
puts " "
puts "Choose choose tables to delete (ex: '124' will delete no. 1, 2 & 4)"
puts " "
puts "[ Press Enter to Update All ]"
puts " "
print " > "

options = STDIN.gets.chomp.gsub(/\D/, "").chars
define_singleton_method(:delete_all?) { options.empty? }

PRICING_TABLES.each_with_index do |table, i| 
	drop_table table if options.include?((i + 1).to_s) || delete_all?
end
