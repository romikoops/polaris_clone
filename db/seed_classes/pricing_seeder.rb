# frozen_string_literal: true

class PricingSeeder
  extend ExcelTools
  DUMMY_DATA_PATH = "#{Rails.root}/db/dummydata"

  def self.perform(filter = {})
    Tenant.where(filter).each do |tenant|
      shipper = tenant.users.shipper.first

      destroy_data_for_tenant(tenant)

      puts "Seeding hubs, itineraries, layovers and pricings for #{tenant.name.light_blue}:"

      request_hash = Dir["#{DUMMY_DATA_PATH}/#{tenant.subdomain}/*.xlsx"]
                     .each_with_object({}) do |file_path, obj|
        file_name = File.basename(file_path, '.xlsx')
        subdomain, sheet_type, other_info = *file_name.split('__')

        if %w(hubs freight_rates local_charges).include?(sheet_type)
          obj[sheet_type] = { 'xlsx' => File.open(file_path) }
        end
      end

      seed_hubs(request_hash['hubs'], shipper)
      seed_freight_rates(request_hash['freight_rates'], shipper)
      seed_local_charges(request_hash['local_charges'], shipper)
    end
  end

  private

  def self.seed_hubs(req, shipper)
    if req.nil?
      puts '  - No hubs sheet'.red
      return
    end

    puts '  - Seeding hubs...'
    ExcelTool::HubsOverwriter.new(params: req, _user: shipper).perform
  end

  def self.seed_freight_rates(req, shipper)
    if req.nil?
      puts '  - No freight rates charges sheet'.red
      return
    end

    puts '  - Seeding freight rates (fcl and lcl)...'
    ExcelTool::FreightRatesOverwriter.new(params: req, _user: shipper, generate: true).perform
  end

  def self.seed_local_charges(req, shipper)
    if req.nil?
      puts '  - No local_charges charges sheet'.red
      return
    end

    puts '  - Seeding local charges...'
    ExcelTool::OverwriteLocalCharges.new(params: req, user: shipper).perform
  end

  def self.destroy_data_for_tenant(tenant)
    puts "Destroying hubs, itineraries, layovers and pricings for #{tenant.name.light_blue}..."

    tenant.itineraries.destroy_all
    tenant.stops.destroy_all
    tenant.trips.destroy_all
    tenant.layovers.destroy_all
    tenant.hubs.destroy_all
  end
end
