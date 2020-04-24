# frozen_string_literal: true

require_dependency 'admiralty_tenants/application_controller'

module AdmiraltyTenants
  class TenantsController < ApplicationController
    before_action :set_tenant, except: %i[index new create]

    def index
      @tenants = ::AdmiraltyTenants::TenantDecorator.decorate_collection(::Tenants::Tenant.order(:subdomain))
    end

    def show; end

    def new
      @tenant = ::AdmiraltyTenants::TenantDecorator.new(Tenants::Tenant.new)
      @render_scope = Tenants::DEFAULT_SCOPE
      @theme = Tenants::Theme.new
      @max_dimensions = ::Legacy::MaxDimensionsBundle.where(tenant_id: @tenant.legacy_id).order(:id)
      @saml_metadatum = Tenants::SamlMetadatum.new(tenant_id: @tenant.id)
    end

    def create
      tenant = Tenants::CreatorService.new(params: tenant_params).perform
      if tenant.persisted?
        Pricings::MarginCreator.create_default_margins(tenant)
        redirect_to tenant_path(tenant) and return # rubocop:disable Style/AndOr
      end

      @tenant = ::AdmiraltyTenants::TenantDecorator.new(tenant)
      @render_scope = Tenants::DEFAULT_SCOPE
      @theme = @tenant.theme || Tenants::Theme.new
      @saml_metadatum = ::Tenants::SamlMetadatum.find_or_initialize_by(tenant_id: @tenant.id)
      @max_dimensions = ::Legacy::MaxDimensionsBundle.where(tenant_id: @tenant.legacy_id).order(:id)
      render :new
    end

    def edit; end

    def update
      @tenant.update(slug: tenant_params[:slug])
      @tenant.legacy.update(name: tenant_params[:name])
      @theme = @tenant.theme || @tenant.build_theme
      @theme.update(tenant_params[:theme]) if tenant_params[:theme].present?
      @scope.update(content: remove_default_values)
      @saml_metadatum.update(content: tenant_params[:saml_metadatum][:content])
      update_max_dimensions

      redirect_to tenant_path(@tenant)
    end

    private

    def set_tenant
      @tenant = ::AdmiraltyTenants::TenantDecorator.new(Tenants::Tenant.find(params[:id]))
      @scope = @tenant.scope || {}
      @render_scope = ::Tenants::ScopeService.new(tenant: @tenant.object).fetch
      @max_dimensions = ::Legacy::MaxDimensionsBundle.where(tenant_id: @tenant.legacy_id).order(:id)
      @saml_metadatum = ::Tenants::SamlMetadatum.find_or_create_by(tenant_id: @tenant.id)
      @theme = @tenant.theme || Tenants::Theme.new
    end

    def update_max_dimensions
      @max_dimensions.each do |md|
        md_params_id = max_dimensions_params[:max_dimensions][md.id.to_s]
        update_hash = md_params_id.to_h.compact
        @max_dimensions.find(md.id).update(update_hash)
      end
    end

    def tenant_params
      params.require(:tenant)
            .permit(
              :name,
              :slug,
              :scope,
              :max_dimensions_bundle,
              saml_metadatum: :content,
              theme: %i[
                primary_color secondary_color bright_primary_color bright_secondary_color
                background small_logo large_logo email_logo white_logo wide_logo booking_process_image
              ]
            )
    end

    def remove_default_values
      edited_scope = JSON.parse(tenant_params[:scope])
      edited_scope.keys.each_with_object({}) do |key, hash|
        hash[key] = edited_scope[key] if edited_scope[key] != ::Tenants::DEFAULT_SCOPE[key]
      end
    end

    def max_dimensions_params
      params.permit(max_dimensions: {})
    end
  end
end
