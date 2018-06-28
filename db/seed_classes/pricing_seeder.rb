# frozen_string_literal: true

class PricingSeeder
  extend ExcelTools
  DUMMY_DATA_PATH = "#{Rails.root}/db/dummydata"

  def self.perform(filter = {})
    Tenant.where(filter).each do |tenant|
      shipper = tenant.users.shipper.first
      
      destroy_data_for_tenant(tenant)
      
      puts "Seeding hubs, itineraries, layovers and pricings for #{tenant.name}..."
      
      request_hash = Dir["#{DUMMY_DATA_PATH}/#{tenant.subdomain}/*.xlsx"]
        .each_with_object({}) do |file_path, obj|
          file_name = File.basename(file_path, ".xlsx")
          subdomain, sheet_type, other_info = *file_name.split("__")
          
          if %(hubs freight_rates local_charges).include?(sheet_type)
            obj[sheet_type] = { 'xlsx' => File.open(file_path) }
          end
        end
        
      puts "  - Seeding hubs..."           
      overwrite_hubs(request_hash["hubs"], shipper)              

      puts "  - Seeding freight rates (fcl and lcl)..."
      overwrite_freight_rates(request_hash["freight_rates"], shipper, true)

      puts "  - Seeding local charges..."
      overwrite_local_charges(request_hash["local_charges"], shipper)
    end
  end

  private

  def self.destroy_data_for_tenant(tenant)
    puts "Destroying hubs, itineraries, layovers and pricings for #{tenant.name}..."

    tenant.itineraries.destroy_all
    tenant.stops.destroy_all
    tenant.trips.destroy_all
    tenant.layovers.destroy_all
    tenant.hubs.destroy_all
  end
end
