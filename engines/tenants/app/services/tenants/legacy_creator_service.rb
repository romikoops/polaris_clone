# frozen_string_literal: true

module Tenants
  class LegacyCreatorService
    attr_reader :tenant, :tenant_params, :legacy_tenant

    DEFAULT_USER_VALUES = {
      password: 'IMC123456789',
      guest: false,
      currency: 'EUR',
      optin_status_id: 1,
      internal: true
    }.freeze

    PROFILE_VALUES = {
      company_name: 'ItsMyCargo GmbH',
      first_name: 'IMC'
    }.freeze

    def initialize(tenant:, tenant_params:)
      @tenant = tenant
      @tenant_params = tenant_params
    end

    def perform
      create_tenant
      return legacy_tenant unless legacy_tenant.valid?

      create_internal_users
      create_default_max_dimensions
      create_cargo_item_types

      legacy_tenant
    end

    def create_tenant
      email_struct = {
        sales: {
          general: ''
        },
        support: {
          general: ''
        }
      }
      tenant.legacy = ::Legacy::Tenant.create(
        subdomain: tenant.slug,
        name: tenant_params[:name],
        theme: {},
        emails: email_struct,
        phones: { main: '', support: '' },
        addresses: { main: '', components: [] }
      )
      tenant.save
      @legacy_tenant = tenant.legacy
    end

    def create_default_max_dimensions
      ::Legacy::MaxDimensionsBundle.create_defaults_for(legacy_tenant)
      ::Legacy::MaxDimensionsBundle.create_defaults_for(legacy_tenant, aggregate: true)
    end

    def create_cargo_item_types
      ::Legacy::TenantCargoItemType.import(
        ::Legacy::CargoItemType.ids.map { |id| { tenant_id: legacy_tenant.id, cargo_item_type_id: id } }
      )
    end

    def create_internal_users
      default_users.map do |user_data|
        legacy_user = ::Legacy::User.create(
          DEFAULT_USER_VALUES.merge(
            email: user_data[:email],
            role: ::Legacy::Role.find_by(name: user_data[:role_name]),
            tenant: legacy_tenant
          )
        )
        create_profile(legacy_user) if legacy_user.persisted?
      end
    end

    private

    def create_profile(legacy_user)
      tenants_user = Tenants::User.find_by(legacy_id: legacy_user.id)
      last_name = legacy_user.role.present? ? legacy_user.role.name.capitalize : ''
      Profiles::Profile.create(
        PROFILE_VALUES.merge(
          user_id: tenants_user.id,
          last_name: last_name
        )
      )
    end

    def default_users
      [
        {
          email: 'shopadmin@itsmycargo.com',
          role_name: 'admin'
        },
        {
          email: 'manager@itsmycargo.com',
          role_name: 'manager'
        },
        {
          email: 'agent@itsmycargo.com',
          role_name: 'agent'
        },
        {
          email: 'shipper@itsmycargo.com',
          role_name: 'shipper'
        }
      ]
    end

    attr_reader :scope, :theme, :scope_params, :theme_params
  end
end
