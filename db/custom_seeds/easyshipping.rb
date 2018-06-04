include ExcelTools
include DocumentTools
include MongoTools
# subdomains = %w(demo greencarrier easyshipping hartrodt)
subdomains = %w(easyshipping easyshipping-sandbox)
subdomains.each do |sub|
# # Tenant.all.each do |tenant|
  tenant = Tenant.find_by_subdomain(sub)
  
  shipper = tenant.users.where(role_id: 2).first
  tenant.itineraries.destroy_all
  # tenant.local_charges.destroy_all
  # tenant.customs_fees.destroy_all
#   # tenant.trucking_pricings.delete_all
#   tenant.hubs.destroy_all
# # # #   # # # # #Overwrite hubs from excel sheet
#   puts "# Overwrite hubs from excel sheet"
#   hubs = File.open("#{Rails.root}/db/dummydata/ez_hubs.xlsx")
#   req = {"xlsx" => hubs}
#   overwrite_hubs(req, shipper)

  public_pricings = File.open("#{Rails.root}/db/dummydata/ez_test_rates.xlsx")
  req = {"xlsx" => public_pricings}
  overwrite_freight_rates(req, shipper, true)

# # # # # #   # # # # # Overwrite public pricings from excel sheet

#   puts "# Overwrite Local Charges From Sheet"
#     local_charges = File.open("#{Rails.root}/db/dummydata/ez_local_charges.xlsx")
#     req = {"xlsx" => local_charges}
#     overwrite_local_charges(req, shipper)


# #   # # # # # # Overwrite trucking data from excel sheet

    # puts "Copenhagen Port"
    # hub = tenant.hubs.find_by_name("Copenhagen Port")
    # trucking = File.open("#{Rails.root}/db/dummydata/es_trucking.xlsx")
    # req = {"xlsx" => trucking}
    # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
    # puts "Copenhagen Railyard"
    # hub = tenant.hubs.find_by_name("Copenhagen Railyard")
    # trucking = File.open("#{Rails.root}/db/dummydata/es_trucking.xlsx")
    # req = {"xlsx" => trucking}
    # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
    # puts "Shanghai Airport ftl"
    # hub = tenant.hubs.find_by_name("Hamburg Railyard")
    # trucking = File.open("#{Rails.root}/db/dummydata/new_ht_trucking_hamburg_ltl.xlsx")
    # req = {"xlsx" => trucking}
    # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
    # awesome_print "City rates done"
    # puts "Hamburg Railyard"
    # hub = tenant.hubs.find_by_name("Hamburg Railyard")
    # trucking = File.open("#{Rails.root}/db/dummydata/new_ht_trucking_hamburg_port_ftl.xlsx")
    # req = {"xlsx" => trucking}
    # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
    

    
end
