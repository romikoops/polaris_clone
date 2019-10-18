# frozen_string_literal: true

module Tenants
  class CreatorService
    def initialize(params:)
      @tenant_params = params.slice(:name, :slug)
      @scope_params = params[:scope]
      @theme_params = params[:theme_attributes]
    end

    def perform
      create_tenant
      create_scope
      create_theme
      create_domain
      create_internal_users

      @tenant
    end

    def create_tenant
      raise ApplicationError::TenantSlugTaken if Tenants::Tenant.exists?(slug: tenant_params[:slug])
      
      @legacy_tenant = ::Legacy::Tenant.create!(
        subdomain: tenant_params[:slug],
        name: tenant_params[:name]
      )
      @tenant = Tenants::Tenant.find_by(legacy_id: legacy_tenant.id)

      create_default_max_dimensions
      create_cargo_item_types
    end

    def create_scope
      @scope = Tenants::Scope.create(target: tenant, content: JSON.parse(scope_params))
    end

    def create_domain
      tenant.domains.create(default: true, domain: "#{tenant.slug}.itsmycargo.shop")
    end

    def create_theme
      @theme = Tenants::Theme.create(theme_params.merge(tenant_id: tenant.id))
    end

    def create_default_max_dimensions
      ::Legacy::MaxDimensionsBundle.create_defaults_for(legacy_tenant)
      ::Legacy::MaxDimensionsBundle.create_defaults_for(legacy_tenant, aggregate: true)
    end

    def create_cargo_item_types
      ::Legacy::TenantCargoItemType.create!(
        ::Legacy::CargoItemType.ids.map { |id| { tenant_id: legacy_tenant.id, cargo_item_type_id: id } }
      )
    end

    def create_internal_users
      ::Legacy::User.create!(
        email: 'shopadmin@itsmycargo.com',
        role: ::Legacy::Role.find_by(name: 'admin'),
        company_name: 'ItsMyCargo GmbH',
        first_name: 'IMC',
        last_name: 'Admin',
        password: 'IMC123456789',
        guest: false,
        currency: 'EUR',
        optin_status_id: 1,
        internal: true,
        tenant: legacy_tenant
      )

      ::Legacy::User.create!(
        email: 'manager@itsmycargo.com',
        role: ::Legacy::Role.find_by(name: 'manager'),
        company_name: 'ItsMyCargo GmbH',
        first_name: 'IMC',
        last_name: 'Admin',
        guest: false,
        password: 'IMC123456789',
        currency: 'EUR',
        optin_status_id: 1,
        internal: true,
        tenant: legacy_tenant
      )

      ::Legacy::User.create!(
        email: 'agent@itsmycargo.com',
        role: ::Legacy::Role.find_by(name: 'agent'),
        company_name: 'ItsMyCargo GmbH',
        first_name: 'IMC',
        last_name: 'Admin',
        guest: false,
        password: 'IMC123456789',
        currency: 'EUR',
        optin_status_id: 1,
        internal: true,
        tenant: legacy_tenant
      )

      ::Legacy::User.create!(
        email: 'shipper@itsmycargo.com',
        role: ::Legacy::Role.find_by(name: 'shipper'),
        company_name: 'ItsMyCargo GmbH',
        first_name: 'IMC',
        last_name: 'Admin',
        guest: false,
        password: 'IMC123456789',
        currency: 'EUR',
        optin_status_id: 1,
        internal: true,
        tenant: legacy_tenant
      )
    end

    private

    attr_reader :scope, :theme, :tenant, :tenant_params, :scope_params, :theme_params, :legacy_tenant
  end
end
