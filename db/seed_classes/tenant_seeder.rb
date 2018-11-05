# frozen_string_literal: true

require_relative 'tenant_seeder_service/max_dimensions'

class TenantSeeder
  DEFAULT_MOT_SCOPE = {
    air: {
      cargo_item: true,
      container: true
    },
    ocean: {
      cargo_item: true,
      container: true
    },
    rail: {
      cargo_item: true,
      container: true
    }
  }.freeze

  def self.perform(filter = {})
    puts 'Seeding Tenants...'
    tenant_data.each do |raw_tenant|
      tenant_attr = raw_tenant.deep_symbolize_keys
      next unless should_perform?(tenant_attr, filter)

      seed_tenant(tenant_attr)
      seed_tenant(tenant_attr, sandbox: true)
    end
  end

  class << self
    private

    def tenant_data
      JSON.parse(File.read("#{Rails.root}/db/dummydata/tenants.json"))
    end

    def seed_tenant(tenant_attr_arg, sandbox: false)
      tenant_attr = tenant_attr_arg.dup

      if sandbox
        tenant_attr[:subdomain] = "#{tenant_attr[:subdomain]}-sandbox"
        tenant_attr[:scope][:modes_of_transport] = DEFAULT_MOT_SCOPE.dup
      end

      puts "  - #{tenant_attr[:subdomain]}..."
      other_data = tenant_attr.delete(:other_data) || {}

      tenant = Tenant.find_by(subdomain: tenant_attr[:subdomain])
      tenant ? tenant.assign_attributes(tenant_attr) : tenant = Tenant.new(tenant_attr)
      tenant.save!

      update_cargo_item_types!(tenant, other_data[:cargo_item_types])
      update_tenant_incoterms!(tenant, other_data[:incoterms])

      max_dimensions_service = TenantSeederService::MaxDimensions.new(
        tenant: tenant,
        other_data: other_data
      )
      max_dimensions_service.update_default_max_dimensions!
      max_dimensions_service.update_max_dimensions!
    end

    def should_perform?(tenant_attr, filter)
      filter.all? do |filter_key, filter_value|
        tenant_attr_value = tenant_attr[filter_key]

        tenant_attr_value == filter_value ||
          (filter_value.is_a?(Array) && filter_value.include?(tenant_attr_value))
      end
    end

    # Cargo Item Types

    CARGO_ITEM_TYPES = CargoItemType.all
    CARGO_ITEM_TYPES_NO_DIMENSIONS = CargoItemType.where(dimension_x: nil, dimension_y: nil)

    def update_cargo_item_types!(tenant, cargo_item_types_attr)
      return if cargo_item_types_attr.nil?

      if cargo_item_types_attr == 'all'
        CARGO_ITEM_TYPES.each do |cargo_item_type|
          TenantCargoItemType.find_or_create_by(tenant: tenant, cargo_item_type: cargo_item_type)
        end
        return
      end

      if cargo_item_types_attr == 'no_dimensions'
        CARGO_ITEM_TYPES_NO_DIMENSIONS.each do |cargo_item_type|
          TenantCargoItemType.find_or_create_by(tenant: tenant, cargo_item_type: cargo_item_type)
        end
        return
      end

      tenant.tenant_cargo_item_types.destroy_all
      cargo_item_types_attr.each do |cargo_item_type_attr|
        cargo_item_type =
          if cargo_item_type_attr.is_a? Hash
            CargoItemType.find_by(cargo_item_type_attr)
          else
            CargoItemType.find_by(
              category: cargo_item_type_attr,
              dimension_x: nil,
              dimension_y: nil,
              area: nil
            )
          end
        TenantCargoItemType.find_or_create_by(tenant: tenant, cargo_item_type: cargo_item_type)
      end
    end

    def update_tenant_incoterms!(tenant, incoterm_array)
      tenant.tenant_incoterms.destroy_all
      if incoterm_array
        incoterm_array.each do |code|
          incoterm = Incoterm.find_by_code(code)
          tenant.tenant_incoterms.find_or_create_by!(incoterm: incoterm)
        end
      else
        Incoterm.all.each do |incoterm|
          tenant.tenant_incoterms.find_or_create_by!(incoterm: incoterm)
        end
      end
    end
  end
end
