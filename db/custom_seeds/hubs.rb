include ExcelTools
include MongoTools
tenant = Tenant.find_by_subdomain("demo")
  shipper = tenant.users.second
puts "# Overwrite hubs from excel sheet"
  hubs = File.open("#{Rails.root}/db/dummydata/1_hubs.xlsx")
  req = {"xlsx" => hubs}
  overwrite_hubs(req, shipper)