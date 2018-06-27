# frozen_string_literal: true

class PricingSeeder
  extend ExcelTools
  DUMMY_DATA_PATH = "#{Rails.root}/db/dummydata"

  def self.perform(filter = {})
    Tenant.where(filter).each do |tenant|
      shipper = tenant.users.shipper.first

      destroy_data_for_tenant(tenant)

      puts "Seeding hubs, itineraries, layovers and pricings for #{tenant.name}..."

      Dir["#{DUMMY_DATA_PATH}/#{tenant.subdomain}/*.xlsx"].each do |file_path|
        file_name = File.basename(file_path, ".xlsx")
        subdomain, sheet_type, other_info = *file_name.split("__")
        
        req = { 'xlsx' => File.open(file_path) }

        case sheet_type
        when "hubs"
          puts "  - Seeding hubs..."
          overwrite_hubs(req, shipper)              
        when "freight_rates"
          puts "  - Seeding freight rates (fcl and lcl)..."
          overwrite_freight_rates(req, shipper, true)
        when "local_charges"
          puts "  - Seeding local charges..."
          overwrite_local_charges(req, shipper)
        end
      end
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
