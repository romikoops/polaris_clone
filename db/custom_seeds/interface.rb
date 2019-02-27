# frozen_string_literal: true

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

def tables_chosen_from_interface(prompt_verb)
  table_names = TableDropper.all_table_names

  choose_table_interface = ChooseOptionInterface.new(
    options: table_names,
    prompt_text: "Please choose one or more tables #{prompt_verb}. " \
                 "(ex: '1,2,4' will choose no. 1, 2 & 4)"
  )

  choose_table_interface.run
  choose_table_interface.chosen_options.map(&:constantize)
end

def choose_tables_to_drop
  TableDropper.perform(only: tables_chosen_from_interface('to drop'))
end

def choose_exceptions
  TableDropper.perform(except: tables_chosen_from_interface('not to drop'))
end

drop_tables_actions = {
  drop_all_tables: -> { TableDropper.perform },
  choose_tables_to_drop__: -> { choose_tables_to_drop },
  choose_exceptions__: -> { choose_exceptions }
}

drop_tables = ActionInterface.new(actions: drop_tables_actions)

### Full Seed ###

def tenant_options_from_interface
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
  MainSeeder.perform(tenant_options_from_interface)
end

def full_seed_without_geometries
  MainSeeder.perform(tenant_options_from_interface.merge(without_geometries: true))
end

### Trucking Pricings ###

trucking_pricings_actions = {
  all_tenants: -> { TruckingPricingSeeder.perform }
}
tenant_subdomains.each_with_object(trucking_pricings_actions) do |subdomain, obj|
  obj[subdomain] = -> { TruckingPricingSeeder.perform(subdomain: subdomain) }
end

trucking_pricings = ActionInterface.new(actions: trucking_pricings_actions)

### Shipments ###

def shipments
  ShipmentSeeder.new(tenant_options_from_interface).perform
end

########## MAIN ##########

main = ActionInterface.new(
  actions: {
    drop_tables__: -> { drop_tables.init },
    full_seed__: -> { full_seed },
    full_seed_without_geometries__: -> { full_seed_without_geometries },
    pricings: -> { puts '(!) Not implemented' },
    trucking_pricings__: -> { trucking_pricings.init },
    shipments: -> { shipments },
    geometries: -> { GeometrySeeder.perform }
  },
  welcome_message: 'Welcome to the ItsMyCargo Seeding Interface'
)

main.init
