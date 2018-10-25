# frozen_string_literal: true

class TenantSeeder
  def self.tenant_data
    JSON.parse(File.read("#{Rails.root}/db/dummydata/tenants.json"))
  end

  def self.sandbox_exec(tenant_attr, other_data)
    tenant_attr[:subdomain] = "#{tenant_attr[:subdomain]}-sandbox"
    tenant = Tenant.find_by(subdomain: tenant_attr[:subdomain])
    tenant_attr[:scope][:modes_of_transport] = {
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
    }
    tenant ? tenant.assign_attributes(tenant_attr) : tenant = Tenant.new(tenant_attr)
    tenant.save!

    update_cargo_item_types!(tenant, other_data[:cargo_item_types])
    update_tenant_incoterms!(tenant, other_data[:incoterms])
    update_max_dimensions!(tenant)
  end

  def self.perform(filter = {})
    puts 'Seeding Tenants...'
    tenant_data.each do |raw_tenant|
      tenant_attr = raw_tenant.deep_symbolize_keys
      next unless should_perform?(tenant_attr, filter)

      puts "  - #{tenant_attr[:subdomain]}..."
      other_data = tenant_attr.delete(:other_data) || {}

      tenant = Tenant.find_by(subdomain: tenant_attr[:subdomain])
      tenant ? tenant.assign_attributes(tenant_attr) : tenant = Tenant.new(tenant_attr)
      tenant.save!

      update_cargo_item_types!(tenant, other_data[:cargo_item_types])
      update_tenant_incoterms!(tenant, other_data[:incoterms])
      update_max_dimensions!(tenant)
      TenantSeeder.sandbox_exec(tenant_attr, other_data)
    end
  end

  private

  def self.should_perform?(tenant_attr, filter)
    filter.all? do |filter_key, filter_value|\
      tenant_attr_value = tenant_attr[filter_key]

      tenant_attr_value == filter_value ||
        (filter_value.is_a?(Array) && filter_value.include?(tenant_attr_value))
    end
  end

  # Cargo Item Types

  CARGO_ITEM_TYPES = CargoItemType.all
  CARGO_ITEM_TYPES_NO_DIMENSIONS = CargoItemType.where(dimension_x: nil, dimension_y: nil)

  def self.update_cargo_item_types!(tenant, cargo_item_types_attr)
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

  def self.update_tenant_incoterms!(tenant, incoterm_array)
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

  def self.update_max_dimensions!(tenant)
    modes_of_transport = %i(general)
    modes_of_transport += %i(air ocean rail).select do |mot|
      tenant.mode_of_transport_in_scope? mot
    end
    MaxDimensionsBundle.create_defaults_for(
      tenant,
      modes_of_transport: modes_of_transport,
      all: true # Creates for aggregate and unit
    )
  end
end
