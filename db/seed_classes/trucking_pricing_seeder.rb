# frozen_string_literal: true

class TruckingPricingSeeder
  extend ExcelTools
  DIRECTIONS = %w(import export).freeze

  DUMMY_DATA_PATH = "#{Rails.root}/db/dummydata"

  def self.perform(filter = {})
    Tenant.where(filter).each do |tenant|
      delete_previous_trucking_pricings(tenant)
      puts "Seeding trucking pricings for #{tenant.name.light_blue}:"

      shipper = tenant.users.shipper.first

      Dir["#{DUMMY_DATA_PATH}/#{tenant.subdomain}/*.xlsx"].each do |file_path|
        file_name = File.basename(file_path, '.xlsx')
        _subdomain, sheet_type, hub_name = *file_name.split('__')

        trucking_load_type_match_data = sheet_type.match(/trucking_(.)/)
        next if trucking_load_type_match_data.nil?

        # trucking_load_type = trucking_load_type_match_data[1]

        if hub_name.nil?
          puts "(!) No hub supplied for trucking sheet #{file_name} (!)".red
          next
        end

        formatted_hub_name = hub_name.split('_').map(&:capitalize).join(' ')
        hub = Hub.find_by(tenant: tenant, name: formatted_hub_name)
        if hub.nil?
          puts "(!) Hub '#{formatted_hub_name}' not found for tenant '#{tenant.subdomain}' (!)".red
          next
        end

        puts "  - #{formatted_hub_name}..."

        req = { 'xlsx' => File.open(file_path) }
        ExcelTool::OverrideTruckingRateByHub.new(
          params: req, _user: shipper, hub_id: hub.id
        ).perform
      end
    end
  end

  private

  def self.delete_previous_trucking_pricings(tenant)
    puts "Deleting trucking pricings for #{tenant.name.light_blue}..."
    tenant.trucking_pricings.delete_all
    HubTrucking.where(id: tenant.hub_truckings.ids).delete_all
  end
end
