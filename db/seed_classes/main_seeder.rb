Dir["#{Rails.root}/db/seed_classes/*.rb"].each { |file| require file }

class MainSeeder
  def self.perform(options = {})
    tenant_filter_options = options[:tenant_filter] || {}

    GeometrySeeder.perform unless options[:without_geometries]

    Dir.chdir("#{Rails.root}/db/custom_seeds/") do
      require './distributions'
      require './countries'
      require './optin_statuses'
      require './roles'
      require './incoterms'
      require './cargo_item_types'
<<<<<<< HEAD
      require './truck_type_availabilities'
=======
      require './mandatory_charges'
>>>>>>> 5195db24ee3792f13f917f1daa951b7f772fe14d
    end
    TenantSeeder.perform(tenant_filter_options)
    AdminSeeder.perform(tenant_filter_options)
    SuperAdminSeeder.perform
    ShipperSeeder.perform(tenant_filter_options)
    VehicleSeeder.perform(tenant_filter_options)
    PricingSeeder.perform(tenant_filter_options)
    TenantSeeder.perform(tenant_filter_options)
    TruckingPricingSeeder.perform(tenant_filter_options)
  end
end
