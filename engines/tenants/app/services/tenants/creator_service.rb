# frozen_string_literal: true

module Tenants
  class CreatorService
    def initialize(params:)
      @tenant_params = params.slice(:name, :slug)
      @scope_params = params[:scope]
      @theme_params = params[:tenants_theme]
    end

    def perform
      create_tenant
      return @tenant unless @tenant.valid?

      Tenants::LegacyCreatorService.new(tenant: @tenant, tenant_params: tenant_params).perform

      @tenant
    end

    def create_tenant
      @tenant = ::Tenants::Tenant.new(slug: tenant_params[:slug]).tap do |tenant|
        tenant.scope = Tenants::Scope.new(target: tenant, content: JSON.parse(scope_params))
        tenant.domains.new(default: true, domain: "#{tenant.slug}.itsmycargo.shop")
        tenant.theme = Tenants::Theme.new(theme_params.merge(tenant_id: tenant.id))
        tenant.save
      end
    end

    private

    attr_reader :scope, :theme, :tenant, :tenant_params, :scope_params, :theme_params, :legacy_tenant
  end
end
