# frozen_string_literal: true

class TenantsController < ApplicationController
  include Response

  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def index
    tenants = if Rails.env.production?
                []
              else
                Tenant.order(:subdomain).map { |t| { label: t.name, value: t } }
              end

    response_handler(tenants)
  end

  def get_tenant
    @tenant = Tenant.find_by_subdomain(params[:name])
    if @tenant
      json_response(@tenant, 200)
    else
      json_response({}, 400)
    end
  end
  deprecate :get_tenant, deprecator: ActiveSupport::Deprecation.new('', Rails.application.railtie_name)

  def fetch_scope
    tenant = Tenant.find_by(id: Rails.env.production? ? tenant_id : (params[:tenant_id] || params[:id]))
    tenants_tenant = Tenants::Tenant.find_by(legacy_id: tenant&.id)
    scope = ::Tenants::ScopeService.new(target: current_user, tenant: tenants_tenant).fetch

    response_handler(scope)
  end

  def show
    tenant = Tenant.find_by(id: Rails.env.production? ? tenant_id : (params[:tenant_id] || params[:id]))
    tenants_tenant = Tenants::Tenant.find_by(legacy_id: tenant.id)
    scope = ::Tenants::ScopeService.new(target: current_user, tenant: tenants_tenant).fetch
    tenant_json = tenant.as_json
    tenant_json['scope'] = scope
    tenant_json['subdomain'] = tenants_tenant.slug

    response_handler(tenant: tenant_json)
  end

  def current
    response_handler(tenant_id: tenant_id)
  end

  private

  def tenant_id
    domains = [
      URI(request.referrer).host,
      ENV.fetch('DEFAULT_TENANT', 'demo.local')
    ]

    domains.each do |domain|
      tenants_domain = Tenants::Domain.where(':domain ~* domain', domain: domain).first
      return tenants_domain.tenant.legacy_id if tenants_domain
    end

    nil
  end
end
