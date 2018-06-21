Dir["#{Rails.root}/db/seed_classes/*.rb"].each { |file| require file }

# Example Interface
# 
# def test_me
#   puts "This is a test"
# end

# ActionInterface.new(
#   actions: {
#     run_my_test_action: -> { test_me },
#   },
#   welcome_message: "Welcome to the Test Seeding Interface"
# ).init


tenant_subdomains = TenantSeeder::TENANT_DATA.map { |data| data[:subdomain] }
table_names       = TableDropper.all_table_names


### Drop Tables ###
  ## Choose Tables to Drop
choose_tables_to_drop_actions = table_names.each_with_object({}) do |table_name, obj|
  obj[table_name.underscore] = -> { TableDropper.perform(only: [table_name.constantize]) }
end
choose_tables_to_drop = ActionInterface.new(actions: choose_tables_to_drop_actions)
  
  ## Choose Exceptions
choose_exceptions_actions = table_names.each_with_object({}) do |table_name, obj|
  obj[table_name.underscore] = -> { TableDropper.perform(except: [table_name.constantize]) }
end
choose_exceptions = ActionInterface.new(actions: choose_exceptions_actions)
  
  ## Main
drop_tables_actions = {
  drop_all_tables:         -> { TableDropper.perform },
  choose_tables_to_drop__: -> { choose_tables_to_drop.init },
  choose_exceptions__:     -> { choose_exceptions.init }
}

drop_tables = ActionInterface.new(actions: drop_tables_actions)


### Full Seed ###

def full_seed_options_from_interface
  tenant_subdomains = TenantSeeder::TENANT_DATA.map { |data| data[:subdomain] }

  choose_tenant_interface = ChooseOptionInterface.new(
    options: [:all_tenants, *tenant_subdomains],
    prompt_text: "Please choose one or more tenants. (ex: '1,2,4' will choose no. 1, 2 & 4)"
  )
  choose_tenant_interface.run
  chosen_options = choose_tenant_interface.chosen_options
  chosen_options.include?(:all_tenants) ? {} : { tenant_filter: { subdomain: chosen_options } }
end

def full_seed
  MainSeeder.perform(full_seed_options_from_interface)
end

def full_seed_without_geometries
  MainSeeder.perform(full_seed_options_from_interface.merge(without_geometries: true))
end


### Trucking Pricings ###

trucking_pricings_actions = {
  all_tenants: -> { TruckingPricingSeeder.perform }
}
tenant_subdomains.each_with_object(trucking_pricings_actions) do |subdomain, obj|
  obj[subdomain] = -> { TruckingPricingSeeder.perform(subdomain: subdomain) }
end

trucking_pricings = ActionInterface.new(actions: trucking_pricings_actions)


########## MAIN ##########

main = ActionInterface.new(
  actions: {
    drop_tables__:                  -> { drop_tables.init },
    full_seed__:                    -> { full_seed },
    full_seed_without_geometries__: -> { full_seed_without_geometries },
    pricings:                       -> { puts "(!) Not implemented" },
    trucking_pricings__:            -> { trucking_pricings.init },
    shipments:                      -> { puts "(!) Not implemented" },
    geometries:                     -> { GeometrySeeder.perform }
  },
  welcome_message: "Welcome to the ItsMyCargo Seeding Interface"
)

main.init
