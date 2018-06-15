Dir["#{Rails.root}/db/seed_classes/*.rb"].each { |file| require file }

class MainSeeder
  def self.perform(options = {})
    require "#{Rails.root}/db/custom_seeds/geometries" unless options[:without_geometries]

    Dir.chdir("#{Rails.root}/db/custom_seeds/") do
      require './distributions'
      require './countries'
      require './optin_statuses'
      require './roles'
      require './incoterms'
      require './cargo_item_types'
      TenantSeeder.perform(options[:tenant_filter] || {})
      require './admin'
      require './super_admin'
      require './shipper'
    end
    VehicleSeeder.perform(options[:tenant_filter] || {})
    PricingSeeder.perform(options[:tenant_filter] || {})
    TruckingPricingSeeder.perform(options[:tenant_filter] || {})
  end
end
