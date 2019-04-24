# frozen_string_literal: true

class TenantsController < ApplicationController
  include Response

  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!
  def index
    tenants = if Rails.env.production?
                []
              else
                Tenant.where("subdomain NOT LIKE '%-sandbox'").order(:subdomain).map { |t| { label: t.name, value: t } }
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

  def fetch_scope
    scope = ::Tenants::ScopeService.new(user: current_user).fetch
    response_handler(scope)
  end

  def show
    tenant = Tenant.find_by(id: Rails.env.production? ? tenant_id : params[:id])
    tenants_tenant = Tenants::Tenant.find_by(legacy_id: tenant.id)
    scope = ::Tenants::ScopeService.new(user: current_user, tenant: tenants_tenant).fetch
    tenant_json = tenant.as_json
    tenant_json['scope'] = scope
    response_handler(tenant: tenant_json)
  end

  def current
    response_handler(tenant_id: tenant_id)
  end

  private

  def tenant_id
    subdomain = [
      URI(request.referrer).host.split('.').first,
      ENV.fetch('DEFAULT_TENANT', 'demo')
    ].find do |subdom|
      Tenant.exists?(subdomain: subdom)
    end

    Tenant.find_by(subdomain: subdomain)&.id
  end
end
