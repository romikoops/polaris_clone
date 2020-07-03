# frozen_string_literal: true

module Tenants
  class CreatorService
    DEFAULT_GROUP_NAME = "default"
    def initialize(params:)
      @tenant_params = params.slice(:name, :slug)
      @scope_params = params[:scope]
      @theme_params = params[:theme]
    end

    def perform
      create_tenant
      return tenant unless tenant.valid?

      create_tenant_defaults
      Tenants::LegacyCreatorService.new(tenant: tenant, tenant_params: tenant_params).perform

      @tenant
    end

    def create_tenant
      @tenant = ::Organizations::Organization.new(slug: tenant_params[:slug]).tap do |tenant|
        tenant.scope = Tenants::Scope.new(target: tenant, content: JSON.parse(scope_params))
        tenant.domains.new(default: true, domain: "#{tenant.slug}.itsmycargo.shop")
        tenant.theme = Tenants::Theme.new(theme_params.merge(organization_id: tenant.id))
        tenant.save
      end
    end

    private

    def create_tenant_defaults
      create_default_group
      create_default_domain
    end

    def create_default_group
      Tenants::Group.create(tenant_id: tenant.id, name: DEFAULT_GROUP_NAME)
    end

    def create_default_domain
      tenant.domains.create(default: true, domain: "#{tenant.slug}.itsmycargo.shop")
    end

    attr_reader :scope, :theme, :tenant, :tenant_params, :scope_params, :theme_params, :legacy_tenant
  end
end
