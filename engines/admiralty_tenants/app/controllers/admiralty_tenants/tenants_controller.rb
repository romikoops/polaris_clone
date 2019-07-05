# frozen_string_literal: true

require_dependency 'admiralty_tenants/application_controller'

module AdmiraltyTenants
  class TenantsController < ApplicationController
    before_action :set_tenant, except: :index

    def index
      @tenants = ::Legacy::Tenant.order(:subdomain).all
    end

    def show
    end

    def edit
    end

    def update
      @tenant.update(
        name: tenant_params[:name],
        subdomain: tenant_params[:subdomain]
      )
      @scope.update(content: remove_default_values)

      redirect_to tenant_path(@tenant)
    end

    private

    def set_tenant
      @tenant = ::Legacy::Tenant.find(params[:id])
      @scope = ::Tenants::Tenant.find_by(legacy_id: params[:id])&.scope || {}
      @render_scope = ::Tenants::ScopeService.new(tenant: ::Tenants::Tenant.find_by(legacy_id: params[:id])).fetch
    end

    def tenant_params
      params.require(:tenant).permit(:name, :subdomain, :scope)
    end

    def remove_default_values
      default_scope = ::Tenants::ScopeService::DEFAULT_SCOPE
      edited_scope = JSON.parse(tenant_params[:scope]).deep_symbolize_keys
      edited_scope.keys.each_with_object({}) do |key, hash|
        hash[key] = edited_scope[key] if edited_scope[key] != default_scope[key]
      end
    end
  end
end
