Dir["#{Rails.root}/db/seed_classes/*.rb"].each { |file| require file }

# Example Interface
# 
# def test_me
#   puts "This is a test"
# end

# SeedingInterface.new(
#   actions: {
#     run_my_test_action: -> { test_me },
#   },
#   welcome_message: "Welcome to the Test Seeding Interface"
# ).init


tenant_subdomains = TenantSeeder::TENANT_DATA.map { |data| data[:subdomain] }

### Full Seed ###

full_seed_actions = { all_tenants: -> { MainSeeder.perform } }
tenant_subdomains.each_with_object(full_seed_actions) do |subdomain, obj|
  obj[subdomain] = -> { MainSeeder.perform(tenant_filter: { subdomain: subdomain }) }
end

full_seed = SeedingInterface.new(actions: full_seed_actions)


### Full Seed Without Geometries ###

full_seed_without_geometries_actions = {
  all_tenants: -> { MainSeeder.perform(without_geometries: true) }
}
tenant_subdomains.each_with_object(full_seed_without_geometries_actions) do |subdomain, obj|
  obj[subdomain] = -> {
    MainSeeder.perform(tenant_filter: { subdomain: subdomain }, without_geometries: true)
  }
end

full_seed_without_geometries = SeedingInterface.new(actions: full_seed_without_geometries_actions)


### Trucking Pricings ###

trucking_pricings_actions = {
  all_tenants: -> { TruckingPricingSeeder.perform }
}
tenant_subdomains.each_with_object(trucking_pricings_actions) do |subdomain, obj|
  obj[subdomain] = -> {
    TruckingPricingSeeder.perform(subdomain: subdomain)
  }
end

trucking_pricings = SeedingInterface.new(actions: trucking_pricings_actions)


########## MAIN ##########

main = SeedingInterface.new(
  actions: {
    full_seed:                    -> { full_seed.init },
    full_seed_without_geometries: -> { full_seed_without_geometries.init },
    pricings:                     -> { puts "(!) Not implemented" },
    trucking_pricings:            -> { trucking_pricings.init },
    shipments:                    -> { puts "(!) Not implemented" },
    geometries:                   -> { GeometrySeeder.perform }
  },
  welcome_message: "Welcome to the ItsMyCargo Seeding Interface"
)

main.init

