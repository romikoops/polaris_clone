# frozen_string_literal: true

require_dependency 'admiralty_tenants/application_controller'

module AdmiraltyTenants
  class TenantsController < ApplicationController
    before_action :set_tenant, except: %i(index new create)

    def index
      @tenants = ::AdmiraltyTenants::TenantDecorator.decorate_collection(::Tenants::Tenant.order(:subdomain))
    end

    def show
    end

    def new
      @tenant = ::AdmiraltyTenants::TenantDecorator.new(Tenants::Tenant.new)
      @render_scope = Tenants::ScopeService::DEFAULT_SCOPE
      @theme = Tenants::Theme.new
      @max_dimensions = ::Legacy::MaxDimensionsBundle.where(tenant_id: @tenant.legacy_id).order(:id)
    end

    def create
      tenant = Tenants::CreatorService.new(params: tenant_params).perform
      if tenant.persisted?
        redirect_to tenant_path(tenant) and return # rubocop:disable Style/AndOr
      end

      @tenant = ::AdmiraltyTenants::TenantDecorator.new(tenant)
      @render_scope = Tenants::ScopeService::DEFAULT_SCOPE
      @theme = Tenants::Theme.new
      @max_dimensions = ::Legacy::MaxDimensionsBundle.where(tenant_id: @tenant.legacy_id).order(:id)
      render :new
    end

    def edit
    end

    def update
      @tenant.update(slug: tenant_params[:slug])
      @tenant.legacy.update(name: tenant_params[:name])
      @scope.update(content: remove_default_values)
      update_max_dimensions

      redirect_to tenant_path(@tenant)
    end

    private

    def set_tenant
      @tenant = ::AdmiraltyTenants::TenantDecorator.new(Tenants::Tenant.find(params[:id]))
      @scope = @tenant.scope || {}
      @render_scope = ::Tenants::ScopeService.new(tenant: @tenant.object).fetch
      @max_dimensions = ::Legacy::MaxDimensionsBundle.where(tenant_id: @tenant.legacy_id).order(:id)
      @theme = @tenant.theme
    end

    def update_max_dimensions
      @max_dimensions.each do |md|
        md_params_id = params[:max_dimensions][md.id.to_s]
        @max_dimensions.find(md.id).update(
          dimension_x: md_params_id[:dimension_x],
          dimension_y: md_params_id[:dimension_y],
          dimension_z: md_params_id[:dimension_z],
          payload_in_kg: md_params_id[:payload_in_kg],
          chargeable_weight: md_params_id[:chargeable_weight]
        )
      end
    end

    def tenant_params
      params.require(:tenant)
            .permit(
              :name,
              :slug,
              :scope,
              :max_dimensions_bundle,
              tenants_theme: %i(
                primary_color secondary_color bright_primary_color bright_secondary_color
                background small_logo large_logo email_logo white_logo wide_logo booking_process_image
              )
            )
    end

    def remove_default_values
      edited_scope = JSON.parse(tenant_params[:scope])
      edited_scope.keys.each_with_object({}) do |key, hash|
        hash[key] = edited_scope[key] if edited_scope[key] != ::Tenants::ScopeService::DEFAULT_SCOPE.with_indifferent_access[key]
      end
    end
  end
end
