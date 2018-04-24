include ExcelTools

puts " "
puts "1 - Overwrite hubs from excel sheet"
puts "2 - Overwrite service charges from excel sheet"
puts "3 - Overwrite dedicated pricings from excel sheet."
puts "4 - Overwrite public pricings from excel sheet"
puts "5 - Overwrite MAERSK pricings from excel sheet"
puts "6 - Overwrite trucking data from excel sheet"
puts " "
puts "Choose wich prices to overwrite (ex: '124' will update no. 1, 2 & 4)"
puts " "
puts "[ Press Enter to Update All ]"
puts " "
print " > "

options = STDIN.gets.chomp.gsub(/\D/, "").chars
define_singleton_method(:run_all?) { options.empty? }

Tenant.all.each do |tenant|
  shipper = tenant.users.second

  if options.include?("1") || run_all?
    # Overwrite hubs from excel sheet
    puts "# Overwrite hubs from excel sheet"
    hubs = File.open("#{Rails.root}/db/dummydata/1_hubs.xlsx")
    req = {"xlsx" => hubs}
    overwrite_hubs(req, shipper)
  end

  if options.include?("2") || run_all?
    # # Overwrite service charges from excel sheet
    puts "# Overwrite service charges from excel sheet"
    service_charges = File.open("#{Rails.root}/db/dummydata/2_service_charges.xlsx")
    req = {"xlsx" => service_charges}
    overwrite_service_charges(req, shipper)
  end
  
  if options.include?("3") || run_all?
    # Overwrite dedicated pricings from excel sheet.
    #   If dedicated == true, shipper.id is automatically inserted.
    puts "# Overwrite dedicated pricings from excel sheet."
    public_pricings = File.open("#{Rails.root}/db/dummydata/new_public_ocean_ptp_rates.xlsx")
    req = {"xlsx" => public_pricings}
    overwrite_mongo_lcl_pricings(req, dedicated = true, shipper)
  end
  
  if options.include?("4") || run_all?
    # # Overwrite public pricings from excel sheet
    puts "# Overwrite public pricings from excel sheet"
    public_pricings = File.open("#{Rails.root}/db/dummydata/new_public_ocean_ptp_rates.xlsx")
    req = {"xlsx" => public_pricings}
    overwrite_mongo_lcl_pricings(req, dedicated = false, shipper)
  end
  
  if options.include?("5") || run_all?
    puts "# Overwrite MAERSK pricings from excel sheet"
    public_pricings = File.open("#{Rails.root}/db/dummydata/mini_MAERSK_FCL.xlsx")
    req = {"xlsx" => public_pricings}
    overwrite_mongo_maersk_fcl_pricings(req, dedicated = false, shipper)
  end
  
  if options.include?("6") || run_all?
    # Overwrite trucking data from excel sheet
    puts "# Overwrite trucking data from excel sheet"
    trucking = File.open("#{Rails.root}/db/dummydata/5_trucking_rates_per_city.xlsx")
    req = {"xlsx" => trucking}
    overwrite_trucking_rates(req, shipper)

    trucking = File.open("#{Rails.root}/db/dummydata/shanghai_trucking.xlsx")
    req = {"xlsx" => trucking}
    overwrite_city_trucking_rates(req, shipper)
  end

  tenant.update_route_details # TODO: check if necessary
end
