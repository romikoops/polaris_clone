# frozen_string_literal: true

require_dependency 'admiralty_tenants/application_controller'

module AdmiraltyTenants
  class TenantsController < ApplicationController
    before_action :set_tenant, except: :index

    def index
      @tenants = ::Tenant.order(:subdomain).all
    end

    def show
    end

    def edit
    end

    def update
      @tenant.update(
        name: tenant_params[:name],
        subdomain: tenant_params[:subdomain],
        scope: JSON.parse(tenant_params[:scope])
      )

      redirect_to tenant_path(@tenant)
    end

    private

    def set_tenant
      @tenant = ::Tenant.find(params[:id])
    end

    def tenant_params
      params.require(:tenant).permit(:name, :subdomain, :scope)
    end
  end
end
